# Copyright IBM Corp. 2026

# Classic Load Balancer should be configured with defensive or strictest desync mitigation mode

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "clb-desync-mode-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elb" "desync_mitigation_mode_check" {
  enforcement_level = input.clb-desync-mode-check-enforcement-level
  # Ensures Classic Load Balancers are configured with defensive or strictest desync mitigation mode to protect against HTTP Desync attacks

  locals {
    # Safe access to desync_mitigation_mode attribute with default fallback
    # Default is "defensive" per AWS provider documentation
    desync_mode = core::try(attrs.desync_mitigation_mode, "defensive")
    elb_name = core::try(attrs.name, "Classic Load Balancer")
    
    # List of allowed desync mitigation modes
    allowed_modes = ["defensive", "strictest"]
    
    # Check if the mode is in the allowed list
    is_compliant = core::contains(local.allowed_modes, local.desync_mode)
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Classic Load Balancer '${local.elb_name}' has desync_mitigation_mode set to '${local.desync_mode}'. Must be 'defensive' or 'strictest' to protect against HTTP Desync attacks. Current mode '${local.desync_mode}' is not compliant with AWS Security Hub control ELB.14"
  }
}
