# Copyright IBM Corp. 2026

policytest {
  targets = [
    "alb-http-to-https-redirection-check.policy.hcl"
  ]
}

resource "aws_lb" "default_action_redirect" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/default-action-redirect/1111111111111111"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "default_action_redirect" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/default-action-redirect/1111111111111111/aaaaaaaaaaaaaaaa"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/default-action-redirect/1111111111111111"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "listener_rule_redirect" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/listener-rule-redirect/2222222222222222"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "listener_rule_redirect" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/listener-rule-redirect/2222222222222222/bbbbbbbbbbbbbbbb"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/listener-rule-redirect/2222222222222222"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/listener-rule-targets/2222222222222222"
      }
    ]
  }
}

resource "aws_lb_listener_rule" "listener_rule_redirect" {
  attrs = {
    listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/listener-rule-redirect/2222222222222222/bbbbbbbbbbbbbbbb"
    action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "no_listener" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/no-listener/3333333333333333"
    load_balancer_type = "application"
  }
}

resource "aws_lb" "http_no_redirect" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-no-redirect/4444444444444444"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "http_no_redirect" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/http-no-redirect/4444444444444444/cccccccccccccccc"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-no-redirect/4444444444444444"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/no-redirect-targets/4444444444444444"
      }
    ]
  }
}

resource "aws_lb" "http_to_http" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-to-http/5555555555555555"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "http_to_http" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/http-to-http/5555555555555555/dddddddddddddddd"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-to-http/5555555555555555"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTP"
          port        = "8080"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "http_8080_only" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-8080-only/6666666666666666"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "http_8080_only" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/http-8080-only/6666666666666666/eeeeeeeeeeeeeeee"
    protocol          = "HTTP"
    port              = 8080
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/http-8080-only/6666666666666666"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "computed_empty_arn_default_action" {
  expect_failure = true
  attrs = {
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "computed_empty_arn_default_action" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/computed-empty-default/8888888888888888/ffffffffffffffff"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = ""
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "computed_empty_arn_listener_rule" {
  expect_failure = true
  attrs = {
    arn                = ""
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "computed_empty_arn_listener_rule" {
  attrs = {
    arn               = ""
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = ""
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/computed-empty-targets/9999999999999999"
      }
    ]
  }
}

resource "aws_lb_listener_rule" "computed_empty_arn_listener_rule" {
  attrs = {
    listener_arn = ""
    action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb" "mixed_http_listeners" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mixed-http-listeners/aaaaaaaaaaaaaaaa"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "mixed_http_listeners_redirect" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/mixed-http-listeners/aaaaaaaaaaaaaaaa/1111111111111111"
    protocol          = "HTTP"
    port              = 8080
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mixed-http-listeners/aaaaaaaaaaaaaaaa"
    default_action = [
      {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
    ]
  }
}

resource "aws_lb_listener" "mixed_http_listeners_no_redirect" {
  attrs = {
    arn               = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/mixed-http-listeners/aaaaaaaaaaaaaaaa/2222222222222222"
    protocol          = "HTTP"
    port              = 80
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mixed-http-listeners/aaaaaaaaaaaaaaaa"
    default_action = [
      {
        type             = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mixed-http-targets/aaaaaaaaaaaaaaaa"
      }
    ]
  }
}

resource "aws_lb" "network_load_balancer" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/network-load-balancer/7777777777777777"
    load_balancer_type = "network"
  }
}
