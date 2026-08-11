# Copyright IBM Corp. 2026

# Database Migration Service replication instances should not be public

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-replication-not-public-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dms_replication_instance" "not_public" {
    enforcement_level = input.dms-replication-not-public-enforcement-level
    locals {
        # Safe access to publicly_accessible attribute with default false
        # (AWS provider default is false when not specified)
        publicly_accessible = core::try(attrs.publicly_accessible, false)
    }

    enforce {
        condition = local.publicly_accessible == false
        error_message = "DMS replication instance must not be publicly accessible. The 'publicly_accessible' attribute is set to true, which exposes the instance to the public internet. Set 'publicly_accessible' to false or omit it (defaults to false) to ensure the instance has a private IP address"
    }
}
