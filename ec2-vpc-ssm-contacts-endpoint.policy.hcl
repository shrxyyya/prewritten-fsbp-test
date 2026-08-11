# Copyright IBM Corp. 2026

# VPCs should be configured with an interface endpoint for Systems Manager Incident Manager Contacts

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-vpc-ssm-contacts-endpoint-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_vpc" "ssm_contacts_endpoint_required" {
  enforcement_level = input.ec2-vpc-ssm-contacts-endpoint-enforcement-level
  // Skip evaluation when the VPC id is unknown (e.g. plan-time computed value).
  // Without this guard, getresources("aws_vpc_endpoint", { vpc_id = null }) returns
  // nothing and every VPC would falsely report "missing endpoint".
  filter = core::try(attrs.id, "") != ""

  locals {
    vpc_id = core::try(attrs.id, "")

    # EC2.58 is a fixed control: only the ssm-contacts endpoint satisfies it.
    service_name = "ssm-contacts"

    all_endpoints       = core::getresources("aws_vpc_endpoint", { vpc_id = local.vpc_id })
    interface_endpoints = [for e in local.all_endpoints : e if core::try(e.vpc_endpoint_type, "") == "Interface"]

    # Region-agnostic match: com.amazonaws.<region>.<service>(-fips)?
    expected_service_regex = "^com\\.amazonaws(-us-gov|\\.cn)?\\.[a-zA-Z0-9-]+\\.${local.service_name}(-fips)?$"
    matching_endpoints = [
      for e in local.interface_endpoints :
      e if core::length(core::regexall(local.expected_service_regex, core::try(e.service_name, ""))) > 0
    ]

    has_endpoint = core::length(local.matching_endpoints) > 0
  }

  enforce {
    condition     = local.vpc_id == "" || local.has_endpoint
    error_message = "VPC '${local.vpc_id}' must have an Interface VPC endpoint for AWS Systems Manager Incident Manager Contacts (e.g. 'com.amazonaws.<region>.ssm-contacts')"
  }
}
