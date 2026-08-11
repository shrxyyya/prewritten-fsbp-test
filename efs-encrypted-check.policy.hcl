# Copyright IBM Corp. 2026

# Elastic File System should be configured to encrypt file data at-rest using AWS KMS

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-encrypted-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_efs_file_system" "encryption_required" {
    enforcement_level = input.efs-encrypted-check-enforcement-level
    enforce {
        condition     = core::try(attrs.encrypted, false)
        error_message = "EFS file system must have encryption at rest enabled. Set 'encrypted = true' in the resource configuration"
    }
}