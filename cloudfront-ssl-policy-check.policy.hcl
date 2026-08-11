# Copyright IBM Corp. 2026

# CloudFront distributions should use the recommended TLS security policy

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudfront-ssl-policy-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "securityPolicies" {
  type = string
  default = "TLSv1.2_2021,TLSv1.2_2025,TLSv1.3_2025"
}

resource_policy "aws_cloudfront_distribution" "recommended_tls_security_policy" {
  enforcement_level = input.cloudfront-ssl-policy-check-enforcement-level
  locals {
    viewer_certificate = core::try(attrs.viewer_certificate, [])
    has_viewer_certificate = core::length(local.viewer_certificate) > 0

    viewer_certificate_block = local.has_viewer_certificate ? local.viewer_certificate[0] : null

    acm_certificate_arn = local.viewer_certificate_block != null ? core::try(local.viewer_certificate_block.acm_certificate_arn, null) : null
    iam_certificate_id = local.viewer_certificate_block != null ? core::try(local.viewer_certificate_block.iam_certificate_id, null) : null
    cloudfront_default_certificate = local.viewer_certificate_block != null ? core::try(local.viewer_certificate_block.cloudfront_default_certificate, false) : false
    minimum_protocol_version = local.viewer_certificate_block != null ? core::try(local.viewer_certificate_block.minimum_protocol_version, null) : null

    uses_custom_ssl_certificate = core::try((local.acm_certificate_arn != null && local.acm_certificate_arn != "") || (local.iam_certificate_id != null && local.iam_certificate_id != ""), false)
    requires_evaluation = core::try(local.uses_custom_ssl_certificate && local.cloudfront_default_certificate == false, false)

    expected_security_policies = "TLSv1.2_2021,TLSv1.2_2025,TLSv1.3_2025"
    input_matches_supported_values = input.securityPolicies == local.expected_security_policies
    recommended_tls_policies = core::split(",", input.securityPolicies)
    uses_recommended_tls_policy = core::try(local.minimum_protocol_version != null && core::contains(local.recommended_tls_policies, local.minimum_protocol_version), false)
  }

  enforce {
    condition = local.input_matches_supported_values
    error_message = "input.securityPolicies must remain 'TLSv1.2_2021,TLSv1.2_2025,TLSv1.3_2025' because this AWS control is not customizable"
  }

  enforce {
    condition = local.requires_evaluation == false || local.uses_recommended_tls_policy
    error_message = "CloudFront distribution must use one of the recommended TLS security policies from input.securityPolicies='${input.securityPolicies}' when configured with a custom SSL certificate. Current minimum_protocol_version: ${local.minimum_protocol_version}"
  }
}
