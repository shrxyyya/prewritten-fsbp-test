# Copyright IBM Corp. 2026

policytest {
  targets = ["appsync-authorization-check.policy.hcl"]
}

# Pass case: AWS_IAM authentication
resource "aws_appsync_graphql_api" "pass_aws_iam_auth" {
  attrs = {
    name = "compliant-api-iam"
    authentication_type = "AWS_IAM"
  }
}

# Pass case: AMAZON_COGNITO_USER_POOLS authentication
resource "aws_appsync_graphql_api" "pass_cognito_auth" {
  attrs = {
    name = "compliant-api-cognito"
    authentication_type = "AMAZON_COGNITO_USER_POOLS"
    user_pool_config = [
      {
        default_action = "ALLOW"
        user_pool_id = "us-east-1_example"
      }
    ]
  }
}

# Pass case: OPENID_CONNECT authentication
resource "aws_appsync_graphql_api" "pass_openid_auth" {
  attrs = {
    name = "compliant-api-openid"
    authentication_type = "OPENID_CONNECT"
    openid_connect_config = [
      {
        issuer = "https://example.com"
      }
    ]
  }
}

# Pass case: AWS_LAMBDA authentication
resource "aws_appsync_graphql_api" "pass_lambda_auth" {
  attrs = {
    name = "compliant-api-lambda"
    authentication_type = "AWS_LAMBDA"
    lambda_authorizer_config = [
      {
        authorizer_uri = "arn:aws:lambda:us-east-1:123456789012:function:my-authorizer"
      }
    ]
  }
}

# Fail case: API_KEY as primary authentication
resource "aws_appsync_graphql_api" "fail_api_key_primary" {
  expect_failure = true
  attrs = {
    name = "non-compliant-api"
    authentication_type = "API_KEY"
  }
}

# Fail case: API_KEY in additional authentication provider
resource "aws_appsync_graphql_api" "fail_api_key_additional" {
  expect_failure = true
  attrs = {
    name = "non-compliant-additional"
    authentication_type = "AWS_IAM"
    additional_authentication_provider = [
      {
        authentication_type = "API_KEY"
      }
    ]
  }
}

# Pass case: Multiple allowed authentication types (AWS_IAM + AWS_LAMBDA)
resource "aws_appsync_graphql_api" "pass_multiple_allowed_auth" {
  attrs = {
    name = "compliant-multiple"
    authentication_type = "AWS_IAM"
    additional_authentication_provider = [
      {
        authentication_type = "AWS_LAMBDA"
        lambda_authorizer_config = [
          {
            authorizer_uri = "arn:aws:lambda:us-east-1:123456789012:function:my-authorizer"
          }
        ]
      }
    ]
  }
}