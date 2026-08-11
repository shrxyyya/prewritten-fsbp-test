# Copyright IBM Corp. 2026

# EBS default encryption should be enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-ebs-encryption-by-default-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ebs_encryption_by_default" "encryption_enabled" {
    enforcement_level = input.ec2-ebs-encryption-by-default-enforcement-level
    enforce {
        condition = core::try(attrs.enabled, true) == true
        error_message = "EBS default encryption resource must have 'enabled = true'"
    }
}