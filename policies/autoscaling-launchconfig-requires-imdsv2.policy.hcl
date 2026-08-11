# Copyright IBM Corp. 2026

# Auto Scaling group launch configurations should configure EC2 instances to require Instance Metadata Service Version 2 (IMDSv2)

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "autoscaling-launchconfig-requires-imdsv2-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_launch_configuration" "imdsv2_required" {
    enforcement_level = input.autoscaling-launchconfig-requires-imdsv2-enforcement-level
    locals {
        # Safe access to metadata_options block
        metadata_options = core::try(attrs.metadata_options, [])
        
        # Check if metadata_options exists and is not empty
        has_metadata_options = core::length(local.metadata_options) > 0
        
        # Extract http_tokens setting (should be "required" for IMDSv2)
        http_tokens = local.has_metadata_options ? core::try(local.metadata_options[0].http_tokens, "optional") : "optional"
        
        # Check if IMDSv2 is properly configured
        is_imdsv2_enabled = local.http_tokens == "required"
    }

    enforce {
        condition = local.is_imdsv2_enabled
        error_message = "Launch configuration must require IMDSv2. Set metadata_options.http_tokens = \"required\" (currently: ${local.http_tokens})"
    }
}

