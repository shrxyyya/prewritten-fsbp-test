# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elb-tls-https-listeners-only.policy.hcl"
  ]
}
# Pass Case 1: Single HTTPS listener
resource "aws_elb" "pass_single_https_listener" {
  attrs = {
    name = "compliant-elb-https"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

# Pass Case 2: Single SSL listener
resource "aws_elb" "pass_single_ssl_listener" {
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

# Pass Case 3: Multiple HTTPS listeners
resource "aws_elb" "pass_multiple_https_listeners" {
  attrs = {
    name = "compliant-elb-multi-https"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 8080
        instance_protocol = "HTTP"
        lb_port          = 8443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

# Pass Case 4: Multiple SSL listeners
resource "aws_elb" "pass_multiple_ssl_listeners" {
  attrs = {
    name = "compliant-elb-multi-ssl"
    listener = [
      {
        instance_port     = 443
        instance_protocol = "SSL"
        lb_port          = 443
        lb_protocol      = "SSL"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 8443
        instance_protocol = "SSL"
        lb_port          = 8443
        lb_protocol      = "SSL"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

# Pass Case 5: Mixed HTTPS and SSL listeners
resource "aws_elb" "pass_mixed_https_ssl_listeners" {
  attrs = {
    name = "compliant-elb-mixed"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 8443
        instance_protocol = "SSL"
        lb_port          = 8443
        lb_protocol      = "SSL"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      }
    ]
  }
}

# Fail Case 1: Single HTTP listener
resource "aws_elb" "fail_single_http_listener" {
  expect_failure = true
  attrs = {
    name = "non-compliant-elb-http"
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

# Fail Case 2: Single TCP listener
resource "aws_elb" "fail_single_tcp_listener" {
  expect_failure = true
  attrs = {
    name = "non-compliant-elb-tcp"
    listener = [
      {
        instance_port     = 3306
        instance_protocol = "TCP"
        lb_port          = 3306
        lb_protocol      = "TCP"
      }
    ]
  }
}

# Fail Case 3: Mixed HTTPS and HTTP listeners
resource "aws_elb" "fail_mixed_https_http_listeners" {
  expect_failure = true
  attrs = {
    name = "non-compliant-elb-mixed-http"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 80
        lb_protocol      = "HTTP"
      }
    ]
  }
}

# Fail Case 4: Multiple listeners with at least one TCP
resource "aws_elb" "fail_multiple_with_tcp_listener" {
  expect_failure = true
  attrs = {
    name = "non-compliant-elb-multi-tcp"
    listener = [
      {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port          = 443
        lb_protocol      = "HTTPS"
        ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/test-cert"
      },
      {
        instance_port     = 3306
        instance_protocol = "TCP"
        lb_port          = 3306
        lb_protocol      = "TCP"
      }
    ]
  }
}