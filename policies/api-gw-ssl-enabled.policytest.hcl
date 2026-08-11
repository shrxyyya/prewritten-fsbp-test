# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gw-ssl-enabled.policy.hcl"
  ]
}

# Pass case: Stage with client certificate configured
resource "aws_api_gateway_stage" "pass_with_client_certificate" {
  attrs = {
    rest_api_id           = "abc123xyz"
    stage_name            = "production"
    deployment_id         = "dep123"
    client_certificate_id = "cert-abc123"
    description           = "Production stage with SSL backend auth"
  }
}

# Fail case: Stage without client certificate (null)
resource "aws_api_gateway_stage" "fail_without_client_certificate" {
  expect_failure = true
  attrs = {
    rest_api_id   = "abc123xyz"
    stage_name    = "development"
    deployment_id = "dep456"
    description   = "Development stage without SSL backend auth"
  }
}

# Fail case: Stage with empty client_certificate_id
resource "aws_api_gateway_stage" "fail_with_empty_certificate_id" {
  expect_failure = true
  attrs = {
    rest_api_id           = "abc123xyz"
    stage_name            = "staging"
    deployment_id         = "dep789"
    client_certificate_id = ""
    description           = "Staging stage with empty certificate ID"
  }
}