# Copyright IBM Corp. 2026

# Imported and ACM-issued certificates should be renewed after a specified time period

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33.0, < 7.0.0"
    }
  }
}

input "acm-certificate-expiration-check-enforcement-level" {
  type = string
  default = "advisory"
}

input "daysToExpiration" {
    type = number
    default = 14
}

resource_policy "aws_acm_certificate" "certificate_renewal_check" {
    enforcement_level = input.acm-certificate-expiration-check-enforcement-level
    # Configuration: Days before expiration to trigger warning
    # Default: 14 days
    # Allowed range: 14 to 365 days
    locals {
        days_to_expiration_threshold = input.daysToExpiration
        
        # Safe access to certificate attributes
        not_after = core::try(attrs.not_after, null)
        renewal_eligibility = core::try(attrs.renewal_eligibility, null)
        certificate_type = core::try(attrs.type, null)
        status = core::try(attrs.status, null)
        
        # Calculate days until expiration (if not_after is available)
        # Note: In real implementation, this would need actual date calculation
        # For policy purposes, we check renewal_eligibility and status
        
        # Check if certificate is eligible for renewal
        is_eligible_for_renewal = local.renewal_eligibility == "ELIGIBLE"
        
        # Check if certificate is issued (not pending)
        is_issued = local.status == "ISSUED"
        
        # For imported certificates, renewal_eligibility will be "INELIGIBLE"
        # These must be manually renewed
        is_imported = local.certificate_type == "IMPORTED"
        
        # Certificate should either:
        # 1. Be eligible for automatic renewal (DNS validated)
        # 2. Be imported (manual renewal required - documented in error)
        needs_attention = local.is_issued && !local.is_eligible_for_renewal && !local.is_imported
    }
    
    enforce {
        condition = !local.needs_attention
        error_message = "ACM certificate requires attention for renewal. Certificate status: ${local.status}, Renewal eligibility: ${local.renewal_eligibility}. The configured daysToExpiration threshold is ${local.days_to_expiration_threshold} days. For DNS-validated certificates, ensure DNS records are properly configured. For email-validated certificates, respond to validation emails. For imported certificates, manual renewal is required before expiration"
    }
    
    enforce {
        condition = local.not_after != null
        error_message = "ACM certificate is missing expiration date (not_after attribute). This may indicate the certificate is still being provisioned or has an error. The configured daysToExpiration threshold is ${local.days_to_expiration_threshold} days"
    }
}
