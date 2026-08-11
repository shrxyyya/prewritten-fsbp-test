# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-https-required.policy.hcl"
    ]
}

# Test 1: PASS - Domain with HTTPS enabled and latest TLS policy
resource "aws_elasticsearch_domain" "compliant" {
  attrs = {
    domain_name = "compliant-domain"
    domain_endpoint_options = [
      {
        enforce_https = true
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 2: PASS - Domain with default HTTPS (true) and latest TLS policy
resource "aws_elasticsearch_domain" "compliant_default" {
  attrs = {
    domain_name = "compliant-default-domain"
    domain_endpoint_options = [
      {
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 3: FAIL - Domain with HTTPS disabled
resource "aws_elasticsearch_domain" "no_https" {
  expect_failure = true
  attrs = {
    domain_name = "no-https-domain"
    domain_endpoint_options = [
      {
        enforce_https = false
        tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
      }
    ]
  }
}

# Test 4: FAIL - Domain with older TLS policy
resource "aws_elasticsearch_domain" "old_tls" {
  expect_failure = true
  attrs = {
    domain_name = "old-tls-domain"
    domain_endpoint_options = [
      {
        enforce_https = true
        tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
      }
    ]
  }
}

# Test 5: FAIL - Domain with HTTPS disabled and old TLS policy
resource "aws_elasticsearch_domain" "non_compliant" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain"
    domain_endpoint_options = [
      {
        enforce_https = false
        tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
      }
    ]
  }
}

# Test 6: FAIL - Domain with missing TLS policy
resource "aws_elasticsearch_domain" "no_tls_policy" {
  expect_failure = true
  attrs = {
    domain_name = "no-tls-policy-domain"
    domain_endpoint_options = [
      {
        enforce_https = true
      }
    ]
  }
}
