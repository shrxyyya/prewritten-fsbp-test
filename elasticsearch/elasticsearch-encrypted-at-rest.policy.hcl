# Copyright IBM Corp. 2026

# Elasticsearch domains should have encryption at-rest enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-encrypted-at-rest-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticsearch_domain" "encrypted_at_rest" {
    enforcement_level = input.elasticsearch-encrypted-at-rest-enforcement-level
    locals {
        encrypt_at_rest = core::try(attrs.encrypt_at_rest, null)
    }

    enforce {
        condition = local.encrypt_at_rest != null && core::try(local.encrypt_at_rest[0].enabled, false)
        error_message = "Elasticsearch domain is not encrypted at rest"
    }
}
