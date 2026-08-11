# Copyright IBM Corp. 2026

# Amazon EC2 instances should not use multiple ENIs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.32.0, < 7.0.0"
    }
  }
}

input "ec2-instance-multiple-eni-check-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_eni_attachments = core::getresources("aws_network_interface_attachment", {})
}

resource_policy "aws_instance" "no_multiple_enis" {
    enforcement_level = input.ec2-instance-multiple-eni-check-enforcement-level
    locals {
        # Count deprecated network_interface blocks (if present)
        deprecated_eni_count = core::try(core::length(attrs.network_interface), 0)
        
        # Count secondary_network_interface blocks (if present)
        secondary_eni_count = core::try(core::length(attrs.secondary_network_interface), 0)
        
        # Find separate ENI attachments for this instance
        attached_enis = [
            for attachment in local.all_eni_attachments :
            attachment if attachment.instance_id == attrs.id
        ]
        attached_eni_count = core::length(local.attached_enis)
        
        # Total ENI count: 1 (primary) + deprecated + secondary + separate attachments
        # Primary network interface is always present (device_index 0)
        total_eni_count = 1 + local.deprecated_eni_count + local.secondary_eni_count + local.attached_eni_count
        
        # Check if instance has multiple ENIs
        has_multiple_enis = local.total_eni_count > 1
        
        # Build detailed error message
        eni_details = local.has_multiple_enis ? "Total ENIs: ${local.total_eni_count} (1 primary + ${local.deprecated_eni_count} deprecated + ${local.secondary_eni_count} secondary + ${local.attached_eni_count} separate attachments)" : ""
    }
    
    enforce {
        condition = !local.has_multiple_enis
        error_message = "[EC2.17] Instance uses multiple ENIs. ${local.eni_details}. Multiple ENIs can create dual-homed instances with multiple subnets, adding network security complexity. Detach additional network interfaces to comply with security requirements"
    }
}
