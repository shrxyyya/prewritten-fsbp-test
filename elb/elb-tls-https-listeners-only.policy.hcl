# Copyright IBM Corp. 2026

# Classic Load Balancer listeners should be configured with HTTPS or TLS termination

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elb-tls-https-listeners-only-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elb" "https_tls_listeners_required" {
  enforcement_level = input.elb-tls-https-listeners-only-enforcement-level
  # Filter to only ELBs that have listeners configured
  filter = attrs.listener != null && core::length(attrs.listener) > 0

  locals {
    elb_name = core::try(attrs.name, "Classic Load Balancer")

    # Identify non-compliant listeners (those not using HTTPS or SSL)
    non_compliant_listeners = [
      for listener in attrs.listener :
      listener if core::try(listener.lb_protocol, "") != "HTTPS" && core::try(listener.lb_protocol, "") != "SSL"
    ]

    # Check if all listeners are compliant (no non-compliant listeners)
    all_secure = core::length(local.non_compliant_listeners) == 0

    # Build detailed error message with non-compliant listener details
    non_compliant_details = [
      for listener in local.non_compliant_listeners :
      "Port ${core::try(listener.lb_port, "unknown")} uses ${core::try(listener.lb_protocol, "unknown")} protocol"
    ]
  }

  enforce {
    condition     = local.all_secure
    error_message = "Classic Load Balancer '${local.elb_name}' has listeners with non-secure protocols. All listeners must use HTTPS or SSL (TLS) for front-end connections. Non-compliant listeners: ${core::join(", ", local.non_compliant_details)}. Please update listener protocols to HTTPS or SSL"
  }
}
