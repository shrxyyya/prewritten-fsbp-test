# Copyright IBM Corp. 2026

# CloudFront distributions should use SNI to serve HTTPS requests

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-sni-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "sni_required" {
    enforcement_level = input.cloudfront-sni-enabled-enforcement-level
    # Pre-filter to only check distributions that are enabled
    filter = core::try(attrs.enabled, false) == true

    locals {
        # Extract viewer_certificate configuration safely
        viewer_cert = core::try(attrs.viewer_certificate[0], null)
        
        # Check if using custom certificate (ACM or IAM)
        has_acm_cert = local.viewer_cert != null && core::try(local.viewer_cert.acm_certificate_arn, null) != null
        has_iam_cert = local.viewer_cert != null && core::try(local.viewer_cert.iam_certificate_id, null) != null
        uses_custom_cert = local.has_acm_cert || local.has_iam_cert
        
        # Check if using CloudFront default certificate
        uses_default_cert = local.viewer_cert != null && core::try(local.viewer_cert.cloudfront_default_certificate, false) == true
        
        # Extract SSL support method
        ssl_support_method = core::try(local.viewer_cert.ssl_support_method, "")
        
        # Check if using dedicated IP (violation)
        uses_dedicated_ip = local.ssl_support_method == "vip" || local.ssl_support_method == "static-ip"
        
        # Check if using SNI (compliant)
        uses_sni = local.ssl_support_method == "sni-only"
    }

    # Enforce SNI when custom certificate is used
    enforce {
        condition = !local.uses_custom_cert || (local.uses_custom_cert && local.uses_sni)
        error_message = "CloudFront distribution uses a custom SSL/TLS certificate but is configured with dedicated IP address (ssl_support_method='${local.ssl_support_method}'). Configure the distribution to use SNI by setting ssl_support_method='sni-only' in the viewer_certificate block. SNI is supported by all modern browsers and clients and avoids extra charges associated with dedicated IP addresses"
    }

    # Additional check: Ensure ssl_support_method is specified when using custom cert
    enforce {
        condition = !local.uses_custom_cert || (local.uses_custom_cert && local.ssl_support_method != "")
        error_message = "CloudFront distribution uses a custom SSL/TLS certificate but does not specify ssl_support_method in the viewer_certificate block. Set ssl_support_method='sni-only' to serve HTTPS requests using Server Name Indication"
    }
}
