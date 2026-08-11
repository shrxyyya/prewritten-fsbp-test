# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudfront-ssl-policy-check.policy.hcl"]
}

resource "aws_cloudfront_distribution" "custom_acm_recommended_tls_2021" {
  attrs = {
    viewer_certificate = [{
      acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
      cloudfront_default_certificate = false
      minimum_protocol_version = "TLSv1.2_2021"
      ssl_support_method = "sni-only"
    }]
  }
}

resource "aws_cloudfront_distribution" "custom_iam_recommended_tls_2025" {
  attrs = {
    viewer_certificate = [{
      iam_certificate_id = "EXAMPLECERTID"
      cloudfront_default_certificate = false
      minimum_protocol_version = "TLSv1.3_2025"
      ssl_support_method = "vip"
    }]
  }
}

resource "aws_cloudfront_distribution" "custom_acm_legacy_tls" {
  expect_failure = true
  attrs = {
    viewer_certificate = [{
      acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/legacy"
      cloudfront_default_certificate = false
      minimum_protocol_version = "TLSv1.1_2016"
      ssl_support_method = "sni-only"
    }]
  }
}

resource "aws_cloudfront_distribution" "default_certificate_out_of_scope" {
  attrs = {
    viewer_certificate = [{
      cloudfront_default_certificate = true
      minimum_protocol_version = "TLSv1"
    }]
  }
}
