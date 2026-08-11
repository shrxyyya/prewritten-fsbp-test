# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gw-xray-enabled.policy.hcl"
  ]
}

# Pass case: X-Ray tracing explicitly enabled
resource "aws_api_gateway_stage" "pass_xray_enabled" {
  attrs = {
    rest_api_id           = "abc123"
    stage_name            = "prod"
    deployment_id         = "dep123"
    xray_tracing_enabled  = true
  }
}

# Fail case: X-Ray tracing explicitly disabled
resource "aws_api_gateway_stage" "fail_xray_disabled" {
  expect_failure = true
  attrs = {
    rest_api_id           = "abc123"
    stage_name            = "prod"
    deployment_id         = "dep123"
    xray_tracing_enabled  = false
  }
}

# Fail case: X-Ray tracing not specified (defaults to false)
resource "aws_api_gateway_stage" "fail_xray_not_specified" {
  expect_failure = true
  attrs = {
    rest_api_id   = "abc123"
    stage_name    = "prod"
    deployment_id = "dep123"
    # xray_tracing_enabled not specified - core::try() will return false
  }
}