# Copyright IBM Corp. 2026

# Application Load Balancer should be configured to redirect all HTTP requests to HTTPS

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "alb-http-to-https-redirection-check-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  alb_http_to_https_listeners      = core::getresources("aws_lb_listener", {})
  alb_http_to_https_listener_rules = core::getresources("aws_lb_listener_rule", {})
}

resource_policy "aws_lb" "http_to_https_redirect" {
  enforcement_level = input.alb-http-to-https-redirection-check-enforcement-level
  filter            = core::try(attrs.load_balancer_type, "application") == "application"

  locals {
    lb_arn = core::try(attrs.arn, "")

    http_port_80_listeners = [
      for listener in local.alb_http_to_https_listeners :
      listener
      if local.lb_arn != ""
        && core::try(listener.load_balancer_arn, "") != ""
        && core::try(listener.load_balancer_arn, "") == local.lb_arn
        && core::try(listener.protocol, "") == "HTTP"
        && core::try(listener.port, 0) == 80
    ]

    http_port_80_listener_arns = [
      for listener in local.http_port_80_listeners :
      core::try(listener.arn, "")
      if core::try(listener.arn, "") != ""
    ]

    default_actions = core::flatten([
      for listener in local.http_port_80_listeners :
      core::try(listener.default_action, [])
    ])

    listener_rule_actions = core::flatten([
      for rule in local.alb_http_to_https_listener_rules :
      core::try(rule.action, [])
      if core::try(rule.listener_arn, "") != ""
        && core::contains(local.http_port_80_listener_arns, core::try(rule.listener_arn, ""))
    ])

    default_https_redirect_actions = [
      for action in local.default_actions :
      action
      if core::try(action.type, "") == "redirect"
        && core::try(action.redirect.protocol, "") == "HTTPS"
    ]

    rule_https_redirect_actions = [
      for action in local.listener_rule_actions :
      action
      if core::try(action.type, "") == "redirect"
        && core::try(action.redirect.protocol, "") == "HTTPS"
    ]

    http_port_80_listeners_without_redirect = [
      for listener in local.http_port_80_listeners :
      listener
      if core::length([
        for action in core::try(listener.default_action, []) :
        action
        if core::try(action.type, "") == "redirect"
          && core::try(action.redirect.protocol, "") == "HTTPS"
      ]) + core::length([
        for rule in local.alb_http_to_https_listener_rules :
        rule
        if core::try(listener.arn, "") != ""
          && core::try(rule.listener_arn, "") == core::try(listener.arn, "")
          && core::length([
            for action in core::try(rule.action, []) :
            action
            if core::try(action.type, "") == "redirect"
              && core::try(action.redirect.protocol, "") == "HTTPS"
          ]) > 0
      ]) == 0
    ]

    has_http_port_80_listener = core::length(local.http_port_80_listeners) > 0
    has_https_redirect        = core::length(local.default_https_redirect_actions) + core::length(local.rule_https_redirect_actions) > 0
  }

  enforce {
    condition     = local.has_http_port_80_listener && local.has_https_redirect && core::length(local.http_port_80_listeners_without_redirect) == 0
    error_message = "Application Load Balancer must have an HTTP listener on port 80 with a redirect action that targets the HTTPS protocol, either in the listener default_action or an associated listener rule."
  }
}
