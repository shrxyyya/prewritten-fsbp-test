# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gwv2-authorization-type-configured.policy.hcl"
  ]
}
# Pass Case 1: Route with AWS_IAM authorization
resource "aws_apigatewayv2_route" "pass_aws_iam" {
  attrs = {
    api_id              = "api123"
    route_key           = "GET /pets"
    authorization_type  = "AWS_IAM"
  }
}

# Pass Case 2: Route with CUSTOM authorization
resource "aws_apigatewayv2_route" "pass_custom" {
  attrs = {
    api_id              = "api123"
    route_key           = "POST /users"
    authorization_type  = "CUSTOM"
    authorizer_id       = "auth123"
  }
}

# Pass Case 3: Route with JWT authorization
resource "aws_apigatewayv2_route" "pass_jwt" {
  attrs = {
    api_id              = "api123"
    route_key           = "GET /orders"
    authorization_type  = "JWT"
    authorizer_id       = "auth456"
  }
}

# Fail Case 1: Route with NONE authorization
resource "aws_apigatewayv2_route" "fail_none" {
  expect_failure = true
  attrs = {
    api_id              = "api123"
    route_key           = "$default"
    authorization_type  = "NONE"
  }
}

# Fail Case 2: Route without authorization_type (defaults to NONE)
resource "aws_apigatewayv2_route" "fail_missing" {
  expect_failure = true
  attrs = {
    api_id     = "api123"
    route_key  = "GET /public"
  }
}

# Fail Case 3: Route with invalid authorization_type
resource "aws_apigatewayv2_route" "fail_invalid" {
  expect_failure = true
  attrs = {
    api_id              = "api123"
    route_key           = "DELETE /items"
    authorization_type  = "INVALID_TYPE"
  }
}