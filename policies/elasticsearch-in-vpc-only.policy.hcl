# Copyright IBM Corp. 2026

# Elasticsearch domains should not be publicly accessible

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-in-vpc-only-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_elasticsearch_domain" "elasticsearch_in_vpc_only" {
  enforcement_level = input.elasticsearch-in-vpc-only-enforcement-level
  locals {
    vpc_options    = core::try(attrs.vpc_options, []) != null ? core::try(attrs.vpc_options, []) : []
    subnet_ids_raw = core::length(local.vpc_options) > 0 ? core::try(local.vpc_options[0].subnet_ids, null) : null
    subnet_ids     = local.subnet_ids_raw != null ? local.subnet_ids_raw : []
    in_vpc         = core::length(local.vpc_options) > 0 && core::length(local.subnet_ids) > 0
  }

  enforce {
    condition     = local.in_vpc
    error_message = "Attribute 'subnet_ids' should not be empty for the attribute 'vpc_options' for 'aws_elasticsearch_domain' resources."
  }
}
