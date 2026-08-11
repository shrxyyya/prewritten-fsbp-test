# Copyright IBM Corp. 2026

# CloudFront distributions should use custom SSL/TLS certificates

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-custom-ssl-certificate-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudfront_distribution" "custom_ssl_required" {
  enforcement_level = input.cloudfront-custom-ssl-certificate-enforcement-level
  locals {
    # Safe access to viewer_certificate block (it's a block, so needs [0] index)
    viewer_cert = core::try(attrs.viewer_certificate[0], null)
    
    # Check if using default CloudFront certificate
    uses_default_cert = core::try(local.viewer_cert.cloudfront_default_certificate, false)
    
    # Check if custom certificate is configured
    has_acm_cert = core::try(local.viewer_cert.acm_certificate_arn, null) != null
    has_iam_cert = core::try(local.viewer_cert.iam_certificate_id, null) != null
    has_custom_cert = local.has_acm_cert || local.has_iam_cert
  }

  enforce {
    condition = !local.uses_default_cert
    error_message = "CloudFront distribution is using the default CloudFront SSL/TLS certificate. Configure a custom certificate using 'acm_certificate_arn' or 'iam_certificate_id' in the viewer_certificate block"
  }

  enforce {
    condition = local.has_custom_cert
    error_message = "CloudFront distribution must have a custom SSL/TLS certificate configured. Set either 'acm_certificate_arn' (recommended) or 'iam_certificate_id' in the viewer_certificate block"
  }
}
