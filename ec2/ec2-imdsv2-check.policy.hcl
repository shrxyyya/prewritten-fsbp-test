# Copyright IBM Corp. 2026

# EC2 instances should use Instance Metadata Service Version 2 (IMDSv2)

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.43.0, < 7.0.0"
    }
  }
}

input "ec2-imdsv2-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ec2_instance_metadata_defaults" "imds_v2" {
    enforcement_level = input.ec2-imdsv2-check-enforcement-level
    enforce {
        condition = core::try(attrs.http_tokens, "no-preference") != "optional"
        error_message = "IMDSv2 is not enabled on the instance"
    }
}
