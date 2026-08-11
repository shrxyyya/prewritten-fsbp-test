# Copyright IBM Corp. 2026

# Policy: APIGateway.11 - API Gateway domain names should use recommended security policies

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "apigateway-domain-name-tls-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_api_gateway_domain_name" "recommended_security_policy" {
    enforcement_level = input.apigateway-domain-name-tls-check-enforcement-level
    locals {
        # Extract security_policy attribute safely
        security_policy = core::try(attrs.security_policy, "")
        
        # Allowed security policies for this control
        allowed_security_policies = ["SecurityPolicy_TLS13_1_3_2025_09", "SecurityPolicy_TLS13_1_3_FIPS_2025_09", "SecurityPolicy_TLS13_1_2_PFS_PQ_2025_09", "SecurityPolicy_TLS13_2025_EDGE", "SecurityPolicy_TLS12_PFS_2025_EDGE"]
        
        # Check if security_policy is set
        has_security_policy = core::try(local.security_policy != "", false)
        
        # Check if security_policy uses an allowed policy
        uses_recommended_policy = core::contains(local.allowed_security_policies, local.security_policy)
    }

    enforce {
        condition = local.has_security_policy && local.uses_recommended_policy
        error_message = "API Gateway domain name must have security_policy explicitly configured. Set security_policy to one of the allowed values (SecurityPolicy_TLS13_1_3_2025_09, SecurityPolicy_TLS13_1_3_FIPS_2025_09, SecurityPolicy_TLS13_1_2_PFS_PQ_2025_09, SecurityPolicy_TLS13_2025_EDGE, SecurityPolicy_TLS12_PFS_2025_EDGE)"
    }
}
