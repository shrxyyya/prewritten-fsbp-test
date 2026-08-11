# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gw-execution-logging-enabled.policy.hcl"
    ]
}


resource "aws_api_gateway_stage" "pass_with_access_logging" {
  attrs = {
    rest_api_id   = "abc123"
    stage_name    = "prod"
    deployment_id = "dep123"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format         = "$context.requestId"
      }
    ]
  }
}

resource "aws_api_gateway_stage" "fail_without_access_logging" {
  expect_failure = true
  attrs = {
    rest_api_id   = "abc123"
    stage_name    = "prod"
    deployment_id = "dep123"
  }
}

resource "aws_api_gateway_stage" "fail_with_empty_access_logging" {
  expect_failure = true
  attrs = {
    rest_api_id         = "abc123"
    stage_name          = "prod"
    deployment_id       = "dep123"
    access_log_settings = []
  }
}

resource "aws_api_gateway_stage" "fail_without_destination_arn" {
  expect_failure = true
  attrs = {
    rest_api_id   = "abc123"
    stage_name    = "prod"
    deployment_id = "dep123"
    access_log_settings = [
      {
        format = "$context.requestId"
      }
    ]
  }
}

# ============================================================================
# Tests for aws_apigatewayv2_stage (WebSocket/HTTP API stages)
# ============================================================================

resource "aws_apigatewayv2_stage" "pass_with_error_logging" {
  attrs = {
    api_id = "abc123"
    name   = "prod"
    default_route_settings = [
      {
        logging_level = "ERROR"
      }
    ]
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format         = "$context.requestId"
      }
    ]
  }
}

resource "aws_apigatewayv2_stage" "pass_with_info_logging" {
  attrs = {
    api_id = "abc123"
    name   = "prod"
    default_route_settings = [
      {
        logging_level = "INFO"
      }
    ]
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format         = "$context.requestId"
      }
    ]
  }
}

resource "aws_apigatewayv2_stage" "fail_without_default_route_settings" {
  expect_failure = true
  attrs = {
    api_id = "abc123"
    name   = "prod"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format         = "$context.requestId"
      }
    ]
  }
}

resource "aws_apigatewayv2_stage" "fail_with_off_logging_level" {
  expect_failure = true
  attrs = {
    api_id = "abc123"
    name   = "prod"
    default_route_settings = [
      {
        logging_level = "OFF"
      }
    ]
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format         = "$context.requestId"
      }
    ]
  }
}

resource "aws_apigatewayv2_stage" "fail_without_access_logging" {
  expect_failure = true
  attrs = {
    api_id = "abc123"
    name   = "prod"
    default_route_settings = [
      {
        logging_level = "ERROR"
      }
    ]
  }
}

resource "aws_apigatewayv2_stage" "fail_with_empty_access_logging" {
  expect_failure = true
  attrs = {
    api_id = "abc123"
    name   = "prod"
    default_route_settings = [
      {
        logging_level = "INFO"
      }
    ]
    access_log_settings = []
  }
}

# ============================================================================
# Tests for aws_api_gateway_method_settings (REST API method settings)
# ============================================================================

resource "aws_api_gateway_method_settings" "pass_with_error_logging" {
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/*"
    settings = [
      {
        logging_level = "ERROR"
      }
    ]
  }
}

resource "aws_api_gateway_method_settings" "pass_with_info_logging" {
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/*"
    settings = [
      {
        logging_level = "INFO"
      }
    ]
  }
}

resource "aws_api_gateway_method_settings" "fail_without_settings" {
  expect_failure = true
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/*"
  }
}

resource "aws_api_gateway_method_settings" "fail_with_empty_settings" {
  expect_failure = true
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/*"
    settings    = []
  }
}

resource "aws_api_gateway_method_settings" "fail_with_off_logging" {
  expect_failure = true
  attrs = {
    rest_api_id = "abc123"
    stage_name  = "prod"
    method_path = "*/*"
    settings = [
      {
        logging_level = "OFF"
      }
    ]
  }
}