# Copyright IBM Corp. 2026

# EC2 network interfaces should have source/destination checking enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-enis-source-destination-check-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_network_interface" "source_dest_check_enabled" {
    enforcement_level = input.ec2-enis-source-destination-check-enabled-enforcement-level
    locals {

        excluded_interface_types = [
            "nat_gateway",
            "gateway_load_balancer",
            "gateway_load_balancer_endpoint",
            "vpc_endpoint",
            "transit_gateway",
            "load_balancer",
            "network_load_balancer"
        ]
        # Safe access to source_dest_check attribute with default true (AWS default)
        source_dest_check = core::try(attrs.source_dest_check, true)

        # Get interface type for error message
        interface_type = core::try(attrs.interface_type, "interface")
        should_check = !core::contains(local.excluded_interface_types, local.interface_type)
    }

    enforce {
        condition = !local.should_check || local.source_dest_check == true
        error_message = "EC2 network interface (type: ${local.interface_type}) must have source/destination checking enabled. Current value: ${local.source_dest_check}. Source/destination checking provides an additional layer of network security by preventing resources from handling unintended traffic and preventing IP address spoofing"
    }
}
