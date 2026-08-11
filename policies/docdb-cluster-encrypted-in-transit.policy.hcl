# Copyright IBM Corp. 2026

# Amazon DocumentDB clusters should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "docdb-cluster-encrypted-in-transit-enforcement-level" {
  type = string
  default = "advisory"
}

input "excludeTlsParameters" {
  type = string
  default = "disabled,enabled"
}

locals {
  all_param_groups = core::getresources("aws_docdb_cluster_parameter_group", {})
}

resource_policy "aws_docdb_cluster" "tls_encryption_required" {
  enforcement_level = input.docdb-cluster-encrypted-in-transit-enforcement-level
  filter = core::try(attrs.db_cluster_parameter_group_name, "") != ""

  locals {
    expected_excluded_tls_parameters = "disabled,enabled"
    param_group_name = core::try(attrs.db_cluster_parameter_group_name, "")
    cluster_identifier = core::try(attrs.cluster_identifier, core::try(attrs.id, "unknown"))

    matching_param_groups = [
      for pg in local.all_param_groups :
      pg if pg.name == local.param_group_name
    ]

    has_param_group = core::length(local.matching_param_groups) > 0
    param_group = local.has_param_group ? local.matching_param_groups[0] : null

    tls_parameters = local.has_param_group ? [
      for param in core::try(local.param_group.parameter, []) :
      param if param.name == "tls"
    ] : []

    tls_value = core::length(local.tls_parameters) > 0 ? core::try(local.tls_parameters[0].value, "") : ""
    excluded_tls_values = core::split(",", input.excludeTlsParameters)
    input_matches_supported_value = input.excludeTlsParameters == local.expected_excluded_tls_parameters
    has_excluded_tls_value = core::contains(local.excluded_tls_values, local.tls_value)
    tls_not_set = local.tls_value == ""
  }

  enforce {
    condition = local.input_matches_supported_value
    error_message = "input.excludeTlsParameters must remain 'disabled,enabled' because this AWS control is not customizable. Current value: '${input.excludeTlsParameters}'."
  }

  enforce {
    condition = local.has_param_group
    error_message = "DocumentDB cluster '${local.cluster_identifier}' references parameter group '${local.param_group_name}' which is not defined in the configuration. This control cannot verify TLS when the associated parameter group is missing or out of sync"
  }

  enforce {
    condition = !local.tls_not_set
    error_message = "DocumentDB cluster '${local.cluster_identifier}' uses parameter group '${local.param_group_name}' which does not have the 'tls' parameter explicitly set. Set the TLS parameter to a value other than the excluded values '${input.excludeTlsParameters}'"
  }

  enforce {
    condition = !local.has_excluded_tls_value
    error_message = "DocumentDB cluster '${local.cluster_identifier}' has TLS set to excluded value '${local.tls_value}' in parameter group '${local.param_group_name}'. The excluded TLS parameter values for this control are '${input.excludeTlsParameters}'"
  }
}
