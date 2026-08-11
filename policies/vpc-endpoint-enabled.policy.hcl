# Copyright IBM Corp. 2026

# VPCs should be configured with an interface endpoint for ECR API

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "vpc-endpoint-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_vpc" "vpc_endpoint_required" {
  enforcement_level = input.vpc-endpoint-enabled-enforcement-level
  # Skip evaluation when the VPC id is unknown (e.g. plan-time computed value).
  # Without this guard, getresources("aws_vpc_endpoint", { vpc_id = null }) returns
  # nothing and every VPC would falsely report "missing endpoint".
  filter = core::try(attrs.id, "") != ""

  locals {
    vpc_id = core::try(attrs.id, "")

    service_names = "ecr.api"
    raw_services  = [for s in core::split(",", local.service_names) : core::trimspace(s)]

    service_patterns = [
      for s in local.raw_services :
      (core::length(core::regexall("^com\\.amazonaws\\.", s)) > 0
        ? "^${s}(-fips)?$"
        : "^com\\.amazonaws\\.[a-z0-9-]+\\.${s}(-fips)?$")
    ]

    all_endpoints = core::getresources("aws_vpc_endpoint", { vpc_id = local.vpc_id })

    # For each required service, the list of matching endpoints.
    matches_per_service = [
      for pattern in local.service_patterns : [
        for e in local.all_endpoints :
        e if core::length(core::regexall(pattern, core::try(e.service_name, ""))) > 0
      ]
    ]

    # Services that have zero matching endpoints.
    missing_services = [
      for idx, matches in local.matches_per_service :
      local.raw_services[idx] if core::length(matches) == 0
    ]

    all_services_have_endpoint = core::length(local.missing_services) == 0
    missing_services_display   = core::length(local.missing_services) > 0 ? core::join(", ", local.missing_services) : ""
  }

  enforce {
    condition     = local.all_services_have_endpoint
    error_message = "VPC '${local.vpc_id}' is missing a VPC endpoint for service(s): ${local.missing_services_display}. The required service 'ecr.api' must have a matching com.amazonaws.<region>.ecr.api endpoint (Interface or Gateway, FIPS variant also accepted)."
  }
}
