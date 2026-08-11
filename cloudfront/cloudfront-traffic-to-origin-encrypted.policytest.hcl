# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudfront-traffic-to-origin-encrypted.policy.hcl"
    ]
}

resource "aws_cloudfront_distribution" "https_only_custom_origin_passes" {
  attrs = {
    comment = "https-only-origin"
    origin = [
      {
        origin_id = "custom-origin-1"
        domain_name = "app.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-1"
        viewer_protocol_policy = "allow-all"
      }
    ]
    enabled = true
  }
}

resource "aws_cloudfront_distribution" "match_viewer_redirect_to_https_passes" {
  attrs = {
    comment = "match-viewer-redirect"
    origin = [
      {
        origin_id = "custom-origin-2"
        domain_name = "app2.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-2"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
    enabled = true
  }
}

resource "aws_cloudfront_distribution" "http_only_custom_origin_fails" {
  expect_failure = true

  attrs = {
    comment = "http-only-origin"
    origin = [
      {
        origin_id = "custom-origin-3"
        domain_name = "app3.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-3"
        viewer_protocol_policy = "https-only"
      }
    ]
    enabled = true
  }
}

resource "aws_cloudfront_distribution" "match_viewer_allow_all_fails" {
  expect_failure = true

  attrs = {
    comment = "match-viewer-allow-all"
    origin = [
      {
        origin_id = "custom-origin-4"
        domain_name = "app4.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-4"
        viewer_protocol_policy = "allow-all"
      }
    ]
    enabled = true
  }
}

# FAIL: default cache behavior is safe (https-only) but an ordered cache
# behavior overrides it with allow-all, paired with a match-viewer origin.
resource "aws_cloudfront_distribution" "ordered_behavior_allow_all_fails" {
  expect_failure = true

  attrs = {
    comment = "ordered-allow-all"
    origin = [
      {
        origin_id = "custom-origin-5"
        domain_name = "app5.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-5"
        viewer_protocol_policy = "https-only"
      }
    ]
    ordered_cache_behavior = [
      {
        path_pattern = "/legacy/*"
        target_origin_id = "custom-origin-5"
        viewer_protocol_policy = "allow-all"
      }
    ]
    enabled = true
  }
}

# PASS: ordered cache behaviors all use safe policies alongside match-viewer origin.
resource "aws_cloudfront_distribution" "ordered_behavior_safe_passes" {
  attrs = {
    comment = "ordered-safe"
    origin = [
      {
        origin_id = "custom-origin-6"
        domain_name = "app6.example.com"
        custom_origin_config = [
          {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1.2"]
          }
        ]
      }
    ]
    default_cache_behavior = [
      {
        target_origin_id = "custom-origin-6"
        viewer_protocol_policy = "redirect-to-https"
      }
    ]
    ordered_cache_behavior = [
      {
        path_pattern = "/api/*"
        target_origin_id = "custom-origin-6"
        viewer_protocol_policy = "https-only"
      }
    ]
    enabled = true
  }
}
