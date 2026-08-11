# Copyright IBM Corp. 2026

# Application and Network Load Balancer listeners should use secure protocols to encrypt data in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elbv2-listener-encryption-in-transit-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb_listener" "secure_protocol_check" {
    enforcement_level = input.elbv2-listener-encryption-in-transit-enforcement-level
    locals {
        # Get all load balancers to determine their types
        all_load_balancers = core::getresources("aws_lb", {})
        
        # Build a map of load balancer ARN to type for O(1) lookup
        lb_type_map = { for lb in local.all_load_balancers : lb.arn => core::try(lb.load_balancer_type, "application") }
        
        # Get the load balancer ARN from the listener
        lb_arn = attrs.load_balancer_arn
        
        # Look up the load balancer type from our cached map
        lb_type = core::try(local.lb_type_map[local.lb_arn], "application")
        
        # Get the listener protocol
        protocol = core::try(attrs.protocol, "")
        
        # Determine if the protocol is secure based on load balancer type
        is_alb = local.lb_type == "application"
        is_nlb = local.lb_type == "network"
        
        # Check if protocol is secure for the load balancer type
        alb_secure = local.is_alb && local.protocol == "HTTPS"
        nlb_secure = local.is_nlb && local.protocol == "TLS"
    }

    enforce {
        condition = local.alb_secure || local.nlb_secure
        error_message = "Load balancer listener must use secure protocol: HTTPS for Application Load Balancers or TLS for Network Load Balancers"
    }
}
