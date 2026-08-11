# Copyright IBM Corp. 2026

# autoscaling-group-elb-healthcheck-required

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "autoscaling-group-elb-healthcheck-required-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_autoscaling_group" "elb_healthcheck_required" {
    enforcement_level = input.autoscaling-group-elb-healthcheck-required-enforcement-level
    locals {
        # Safely get attributes with core::try() using empty lists as defaults
        load_balancers_value = core::try(attrs.load_balancers, [])
        target_group_arns_value = core::try(attrs.target_group_arns, [])
        
        # Check if associated with Classic Load Balancer
        has_classic_lb = core::length(local.load_balancers_value) > 0
        
        # Check if associated with ALB/NLB via target groups
        has_target_groups = core::length(local.target_group_arns_value) > 0
        
        # Check if any load balancer is associated
        has_any_lb = local.has_classic_lb || local.has_target_groups
        
        # Safely get health_check_type with default "EC2"
        health_check_type = core::try(attrs.health_check_type, "EC2")
        
        # Determine association type for error message
        lb_type = local.has_classic_lb ? "Classic Load Balancer" : "Application/Network Load Balancer"
    }
    
    # Filter to only Auto Scaling groups that are associated with load balancers
    filter = local.has_any_lb

    enforce {
        condition = local.health_check_type == "ELB"
        error_message = "Auto Scaling group is associated with ${local.lb_type} but does not use ELB health checks. Current health_check_type: '${local.health_check_type}'. Set health_check_type to 'ELB' to use load balancer health checks for improved availability monitoring"
    }
}
