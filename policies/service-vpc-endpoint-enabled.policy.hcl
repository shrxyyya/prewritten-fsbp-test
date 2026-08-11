# Copyright IBM Corp. 2026

# Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "service-vpc-endpoint-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

# Validate each VPC has an EC2 interface endpoint.
resource_policy "aws_vpc" "ec2_service_vpc_endpoint_enabled" {
    enforcement_level = input.service-vpc-endpoint-enabled-enforcement-level
    locals {
        vpc_id = core::try(attrs.id, "")
        has_known_vpc_id = core::try(attrs.id != "", false)

        service_name = "ec2"

        all_vpc_endpoints = core::getresources("aws_vpc_endpoint", { vpc_id = local.vpc_id })

        matching_endpoints = [
            for endpoint in local.all_vpc_endpoints :
            endpoint if (
                core::try(endpoint.vpc_endpoint_type, "") == "Interface" &&
                core::length(core::regexall("\\.${local.service_name}(-fips)?$", core::try(endpoint.service_name, ""))) > 0
            )
        ]

        has_endpoint = local.has_known_vpc_id && core::try(core::length(local.matching_endpoints) > 0, false)

        valid_endpoints = [
            for endpoint in local.matching_endpoints :
            endpoint if (
                core::length(core::try(endpoint.subnet_ids, [])) > 0 &&
                core::length(core::try(endpoint.security_group_ids, [])) > 0
            )
        ]

        has_valid_endpoint = local.has_known_vpc_id && core::try(core::length(local.valid_endpoints) > 0, false)
    }

    enforce {
        condition = !local.has_known_vpc_id || local.has_endpoint
        error_message = "VPC must have an interface VPC endpoint created for the Amazon EC2 service. Create an aws_vpc_endpoint resource with service_name ending in '.ec2' for VPC id ${attrs.id}"
    }

    enforce {
        condition = !local.has_known_vpc_id || local.has_valid_endpoint
        error_message = "VPC EC2 interface endpoint must include subnet_ids and security_group_ids for proper connectivity and access control"
    }
}