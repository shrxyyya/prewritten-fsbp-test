# Copyright IBM Corp. 2026

# CloudTrail should have encryption at-rest enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloud-trail-encryption-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudtrail" "encryption-at-rest" {
    enforcement_level = input.cloud-trail-encryption-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.kms_key_id, "") != ""
        error_message = "CloudTrail is not encrypted at rest"
    }
}
