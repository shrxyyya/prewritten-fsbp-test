# Copyright IBM Corp. 2026

# Attached Amazon EBS volumes should be encrypted at-rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "encrypted-volumes-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ebs_volume" "encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        encrypted = core::try(attrs.encrypted, false)
    }

    enforce {
        condition = local.encrypted == true
        error_message = "EBS volume must have encryption enabled. Set 'encrypted = true' in the resource configuration. Note: This control only applies to attached volumes at runtime"
    }
}

resource_policy "aws_instance" "ebs_encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        # Safely get ebs_block_device attribute
        ebs_devices = core::try(attrs.ebs_block_device, [])
        has_ebs_devices = core::length(local.ebs_devices) > 0
        
        # Check all EBS block devices for encryption
        unencrypted_ebs_devices = [
            for device in local.ebs_devices :
            device if core::try(device.encrypted, false) != true
        ]
        
        all_ebs_encrypted = core::length(local.unencrypted_ebs_devices) == 0
    }

    # Filter to instances that have EBS block devices
    filter = local.has_ebs_devices

    enforce {
        condition = local.all_ebs_encrypted
        error_message = "EC2 instance has ${core::length(local.unencrypted_ebs_devices)} unencrypted EBS block device(s). All EBS block devices must have 'encrypted = true'"
    }
}

resource_policy "aws_instance" "root_encryption_required" {
    enforcement_level = input.encrypted-volumes-enforcement-level
    locals {
        # Safely get root_block_device attribute
        root_devices = core::try(attrs.root_block_device, [])
        has_root_device = core::length(local.root_devices) > 0
        
        # Root block device is a list with single element
        root_device = local.has_root_device ? local.root_devices[0] : null
        root_encrypted = core::try(local.root_device.encrypted, false)
    }

    # Filter to instances that have root block device configuration
    filter = local.has_root_device

    enforce {
        condition = local.root_encrypted == true
        error_message = "EC2 instance has an unencrypted root block device. Set 'encrypted = true' in the root_block_device configuration"
    }
}
