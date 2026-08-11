# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elb-predefined-security-policy-ssl-check.policy.hcl"
  ]
}
# Test 1: PASS - HTTPS listener with required security policy
resource "aws_elb" "compliant_https" {
  attrs = {
    name = "compliant-elb-https"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "HTTPS"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

resource "aws_load_balancer_policy" "required_policy" {
  attrs = {
    load_balancer_name = "compliant-elb-https"
    policy_name        = "required-ssl-policy"
    policy_type_name   = "SSLNegotiationPolicyType"
    policy_attribute = [
      {
        name  = "Reference-Security-Policy"
        value = "ELBSecurityPolicy-TLS-1-2-2017-01"
      }
    ]
  }
}

resource "aws_load_balancer_listener_policy" "attach_policy" {
  attrs = {
    load_balancer_name = "compliant-elb-https"
    load_balancer_port = 443
    policy_names       = ["required-ssl-policy"]
  }
}

# Test 2: PASS - SSL listener with required security policy
resource "aws_elb" "compliant_ssl" {
  attrs = {
    name = "compliant-elb-ssl"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "SSL"
        lb_port          = 443
        lb_protocol      = "SSL"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

resource "aws_load_balancer_policy" "ssl_policy" {
  attrs = {
    load_balancer_name = "compliant-elb-ssl"
    policy_name        = "ssl-security-policy"
    policy_type_name   = "SSLNegotiationPolicyType"
    policy_attribute = [
      {
        name  = "Reference-Security-Policy"
        value = "ELBSecurityPolicy-TLS-1-2-2017-01"
      }
    ]
  }
}

resource "aws_load_balancer_listener_policy" "ssl_attach" {
  attrs = {
    load_balancer_name = "compliant-elb-ssl"
    load_balancer_port = 443
    policy_names       = ["ssl-security-policy"]
  }
}

# Test 3: PASS - HTTP only listener (no SSL/HTTPS)
resource "aws_elb" "http_only" {
  attrs = {
    name = "http-only-elb"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}

# Test 4: FAIL - HTTPS listener without security policy
resource "aws_elb" "non_compliant_no_policy" {
  expect_failure = true
  attrs = {
    name = "non-compliant-elb"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "HTTPS"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

# Test 5: FAIL - HTTPS listener with wrong security policy
resource "aws_elb" "wrong_policy" {
  expect_failure = true
  attrs = {
    name = "wrong-policy-elb"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "HTTPS"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

resource "aws_load_balancer_policy" "wrong_policy" {
  attrs = {
    load_balancer_name = "wrong-policy-elb"
    policy_name        = "old-ssl-policy"
    policy_type_name   = "SSLNegotiationPolicyType"
    policy_attribute = [
      {
        name  = "Reference-Security-Policy"
        value = "ELBSecurityPolicy-2016-08"
      }
    ]
  }
}

resource "aws_load_balancer_listener_policy" "wrong_attach" {
  attrs = {
    load_balancer_name = "wrong-policy-elb"
    load_balancer_port = 443
    policy_names       = ["old-ssl-policy"]
  }
}

# Test 6: FAIL - Multiple HTTPS listeners, only one has required policy
resource "aws_elb" "mixed_compliance" {
  expect_failure = true
  attrs = {
    name = "mixed-compliance-elb"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "HTTPS"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 8443
        instance_protocol = "HTTPS"
        lb_port          = 8443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

resource "aws_load_balancer_policy" "good_policy" {
  attrs = {
    load_balancer_name = "mixed-compliance-elb"
    policy_name        = "good-policy"
    policy_type_name   = "SSLNegotiationPolicyType"
    policy_attribute = [
      {
        name  = "Reference-Security-Policy"
        value = "ELBSecurityPolicy-TLS-1-2-2017-01"
      }
    ]
  }
}

resource "aws_load_balancer_listener_policy" "attach_443" {
  attrs = {
    load_balancer_name = "mixed-compliance-elb"
    load_balancer_port = 443
    policy_names       = ["good-policy"]
  }
}