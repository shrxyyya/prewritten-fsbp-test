# Copyright IBM Corp. 2026

# EC2 launch templates should enable encryption for attached EBS volumes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-launch-templates-ebs-volume-encrypted-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_launch_template" "ebs_encryption_enabled" {
    enforcement_level = input.ec2-launch-templates-ebs-volume-encrypted-enforcement-level
    filter = core::length(core::try(attrs.block_device_mappings, [])) > 0

    locals {
        # Filter for block device mappings that have EBS volumes without encryption
        unencrypted_devices = [
            for mapping in core::try(attrs.block_device_mappings, []) : mapping
            if core::length(core::try(mapping.ebs, [])) > 0 && !core::try(mapping.ebs[0].encrypted, false)
        ]
    }

    enforce {
        condition = core::length(local.unencrypted_devices) == 0
        error_message = "Launch template has EBS volume(s) without encryption enabled. Set 'block_device_mappings.ebs.encrypted = true' for all EBS volumes"
    }
}
