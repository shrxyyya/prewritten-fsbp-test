# Copyright IBM Corp. 2026

# Classic Load Balancers with SSL listeners should use a predefined security policy that has strong AWS Configuration

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elb-predefined-security-policy-ssl-check-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
    all_lb_policies = core::getresources("aws_load_balancer_policy", {})
    all_listener_policies = core::getresources("aws_load_balancer_listener_policy", {})
}

resource_policy "aws_elb" "ssl_predefined_security_policy" {
    enforcement_level = input.elb-predefined-security-policy-ssl-check-enforcement-level
    # Filter to only ELBs that have listeners (skip if no listeners configured)
    filter = attrs.listener != null && core::length(attrs.listener) > 0

    locals {
        # Extract all HTTPS/SSL listeners from this ELB
        ssl_listeners = [for listener in attrs.listener : listener if core::contains(["HTTPS", "SSL"], listener.lb_protocol)]

        # Get the ELB name for querying related resources and reporting
        elb_name = core::try(attrs.name, "Classic Load Balancer")

        # Find all listener policies attached to this ELB
        elb_listener_policies = [for lp in local.all_listener_policies : lp if lp.load_balancer_name == local.elb_name]

        # Find all load balancer policies for this ELB with the required security policy
        elb_policies_with_required = [for policy in local.all_lb_policies : policy if policy.load_balancer_name == local.elb_name && core::length([for attr in core::try(policy.policy_attribute, []) : attr if attr.name == "Reference-Security-Policy" && attr.value == "ELBSecurityPolicy-TLS-1-2-2017-01"]) > 0]

        # Get policy names that have the required security policy
        compliant_policy_names = [for policy in local.elb_policies_with_required : policy.policy_name]

        # Find SSL listeners that have compliant policies attached
        compliant_listeners = [for listener in local.ssl_listeners : listener if core::length([for lp in local.elb_listener_policies : lp if lp.load_balancer_port == listener.lb_port && core::length([for pname in lp.policy_names : pname if core::contains(local.compliant_policy_names, pname)]) > 0]) > 0]

        # Check if all SSL listeners are compliant
        all_ssl_listeners_compliant = core::length(local.ssl_listeners) == 0 || core::length(local.compliant_listeners) == core::length(local.ssl_listeners)

        # Count non-compliant listeners
        non_compliant_count = core::length(local.ssl_listeners) - core::length(local.compliant_listeners)
    }

    enforce {
        condition = local.all_ssl_listeners_compliant
        error_message = "Classic Load Balancer '${local.elb_name}' has ${local.non_compliant_count} SSL/HTTPS listener(s) that do not use the required security policy 'ELBSecurityPolicy-TLS-1-2-2017-01'. All SSL/HTTPS listeners must use this predefined security policy. Configure the security policy using aws_load_balancer_policy and aws_load_balancer_listener_policy resources"
    }
}