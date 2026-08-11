# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gw-associated-with-waf.policy.hcl"
  ]
}
# Test 1: API Gateway stage WITH WAF association (via aws_wafv2_web_acl_association) - PASS
resource "aws_wafv2_web_acl_association" "stage_with_waf" {
  skip = true
  attrs = {
    resource_arn = "arn:aws:apigateway:*::/restapis/abc123/stages/prod"
    web_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test-acl/a1b2c3d4"
  }
}

resource "aws_api_gateway_stage" "stage_with_waf_association" {
  attrs = {
    rest_api_id = "abc123"
    stage_name = "prod"
    deployment_id = "dep123"
  }
}

# Test 2: API Gateway stage WITHOUT WAF association - FAIL
resource "aws_api_gateway_stage" "stage_without_waf" {
  expect_failure = true
  attrs = {
    rest_api_id = "xyz789"
    stage_name = "dev"
    deployment_id = "dep456"
  }
}

# Test 3: API Gateway stage with web_acl_arn attribute set - PASS
resource "aws_api_gateway_stage" "stage_with_web_acl_arn" {
  attrs = {
    rest_api_id = "def456"
    stage_name = "staging"
    deployment_id = "dep789"
    web_acl_arn = "arn:aws:wafv2:us-west-2:123456789012:regional/webacl/staging-acl/e5f6g7h8"
  }
}

# Test 4: Multiple API Gateway stages, some with WAF, some without
resource "aws_wafv2_web_acl_association" "multi_stage_waf" {
  skip = true
  attrs = {
    resource_arn = "arn:aws:apigateway:*::/restapis/mno345/stages/production"
    web_acl_arn = "arn:aws:wafv2:us-west-2:123456789012:regional/webacl/prod-acl/q7r8s9t0"
  }
}

resource "aws_api_gateway_stage" "multi_stage_protected" {
  attrs = {
    rest_api_id = "mno345"
    stage_name = "production"
    deployment_id = "dep999"
  }
}

resource "aws_api_gateway_stage" "multi_stage_unprotected" {
  expect_failure = true
  attrs = {
    rest_api_id = "mno345"
    stage_name = "test"
    deployment_id = "dep888"
  }
}
