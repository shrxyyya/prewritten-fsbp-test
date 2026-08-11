# Copyright IBM Corp. 2026

policytest {
  targets = ["elbv2-predefined-security-policy-ssl-check.policy.hcl"]
}

# Test 1: HTTPS listener with recommended SSL policy (ELBSecurityPolicy-TLS13-1-3-2021-06) - PASS
resource "aws_lb_listener" "https_compliant_tls13_1_3" {
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-3-2021-06"
    port        = 443
  }
}

# Test 2: TLS listener with recommended SSL policy (ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04) - PASS
resource "aws_lb_listener" "tls_compliant_tls13_1_3_fips" {
  attrs = {
    protocol    = "TLS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04"
    port        = 443
  }
}

# Test 3: HTTPS listener with TLS13-1-2-Res-2021-06 policy - PASS
resource "aws_lb_listener" "https_res_tls13_1_2" {
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
    port        = 443
  }
}

# Test 4: TLS listener with TLS13-1-2-Res-FIPS-2023-04 policy - PASS
resource "aws_lb_listener" "tls_res_fips" {
  attrs = {
    protocol    = "TLS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-Res-FIPS-2023-04"
    port        = 443
  }
}

# Test 5: HTTPS listener with TLS13-1-2-Res-PQ-2025-09 policy - PASS
resource "aws_lb_listener" "https_res_pq" {
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
    port        = 443
  }
}

# Test 6: TLS listener with TLS13-1-3-PQ-2025-09 policy - PASS
resource "aws_lb_listener" "tls_tls13_pq" {
  attrs = {
    protocol    = "TLS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-3-PQ-2025-09"
    port        = 443
  }
}

# Test 7: HTTPS listener with TLS13-1-2-Res-FIPS-PQ-2025-09 policy - PASS
resource "aws_lb_listener" "https_res_fips_pq" {
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-Res-FIPS-PQ-2025-09"
    port        = 443
  }
}

# Test 8: TLS listener with TLS13-1-3-FIPS-PQ-2025-09 policy - PASS
resource "aws_lb_listener" "tls_tls13_fips_pq" {
  attrs = {
    protocol    = "TLS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-3-FIPS-PQ-2025-09"
    port        = 443
  }
}

# Test 9: HTTPS listener with non-recommended SSL policy (ELBSecurityPolicy-2016-08) - FAIL
resource "aws_lb_listener" "https_non_compliant_2016" {
  expect_failure = true
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-2016-08"
    port        = 443
  }
}

# Test 10: TLS listener with older SSL policy (ELBSecurityPolicy-TLS-1-2-2017-01) - FAIL
resource "aws_lb_listener" "tls_non_compliant_2017" {
  expect_failure = true
  attrs = {
    protocol    = "TLS"
    ssl_policy  = "ELBSecurityPolicy-TLS-1-2-2017-01"
    port        = 443
  }
}

# Test 11: HTTPS listener without explicit ssl_policy (defaults to ELBSecurityPolicy-2016-08) - FAIL
resource "aws_lb_listener" "https_default_policy" {
  expect_failure = true
  attrs = {
    protocol    = "HTTPS"
    port        = 443
  }
}

# Test 12: HTTP listener (should be filtered out, no evaluation)
resource "aws_lb_listener" "http_listener" {
  attrs = {
    protocol    = "HTTP"
    port        = 80
  }
}

# Test 13: TCP listener (should be filtered out, no evaluation)
resource "aws_lb_listener" "tcp_listener" {
  attrs = {
    protocol    = "TCP"
    port        = 8080
  }
}

# Test 14: HTTPS listener with older recommended-in-the-past policy that is no longer allowed - FAIL
resource "aws_lb_listener" "https_old_tls13_1_2" {
  expect_failure = true
  attrs = {
    protocol    = "HTTPS"
    ssl_policy  = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    port        = 443
  }
}