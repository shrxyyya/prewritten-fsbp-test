# Copyright IBM Corp. 2026

# API Gateway should be associated with a WAF Web ACL

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "api-gw-associated-with-waf-enforcement-level" {
  type = string
  default = "advisory"
}

# Cache all WAF Web ACL associations at top level for performance
locals {
  all_waf_associations = core::getresources("aws_wafv2_web_acl_association", {})
}

resource_policy "aws_api_gateway_stage" "waf_association_required" {
  enforcement_level = input.api-gw-associated-with-waf-enforcement-level
  locals {
    # Construct the stage ARN for lookup
    # Format: arn:aws:apigateway:{region}::/restapis/{rest-api-id}/stages/{stage-name}
    stage_arn = "arn:aws:apigateway:*::/restapis/${attrs.rest_api_id}/stages/${attrs.stage_name}"
    
    # Check if this stage has a WAF association by looking for matching resource_arn
    matching_associations = [
      for assoc in local.all_waf_associations :
      assoc if core::try(assoc.resource_arn, "") == local.stage_arn
    ]
    has_waf_association = core::length(local.matching_associations) > 0
    
    # Alternative check: web_acl_arn attribute (read-only, set by association)
    web_acl_arn_value = core::try(attrs.web_acl_arn, "")
    has_web_acl_arn = local.web_acl_arn_value != ""
  }

  enforce {
    condition = local.has_waf_association || local.has_web_acl_arn
    error_message = "API Gateway stage '${attrs.rest_api_id}/${attrs.stage_name}' must be associated with an AWS WAF Web ACL. Create an aws_wafv2_web_acl_association resource with resource_arn pointing to this stage's ARN, or ensure the stage has a web_acl_arn configured"
  }
}