# Copyright IBM Corp. 2026

# Application, Gateway, and Network Load Balancers should have deletion protection enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elb-deletion-protection-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb" "deletion_protection_enabled" {
    enforcement_level = input.elb-deletion-protection-enabled-enforcement-level
    enforce {
        condition = core::try(attrs.enable_deletion_protection, false) == true
        error_message = "Load balancer (application, network or gateway) does not have deletion protection enabled. Set 'enable_deletion_protection = true' to prevent accidental deletion"
    }
}
