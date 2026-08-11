# Copyright IBM Corp. 2026

policytest {
  targets = [
    "api-gwv2-access-logs-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Complete access_log_settings with both destination_arn and format
resource "aws_apigatewayv2_stage" "pass_complete_access_log_settings" {
  attrs = {
    api_id = "abc123xyz"
    name = "production"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
        format = "$context.requestId $context.error.message $context.error.messageString"
      }
    ]
  }
}

# Test 2: FAIL - No access_log_settings block
resource "aws_apigatewayv2_stage" "fail_missing_access_log_settings" {
  expect_failure = true
  attrs = {
    api_id = "abc123xyz"
    name = "development"
  }
}

# Test 3: FAIL - access_log_settings exists but missing destination_arn
resource "aws_apigatewayv2_stage" "fail_missing_destination_arn" {
  expect_failure = true
  attrs = {
    api_id = "abc123xyz"
    name = "staging"
    access_log_settings = [
      {
        format = "$context.requestId"
      }
    ]
  }
}

# Test 4: FAIL - access_log_settings exists but missing format
resource "aws_apigatewayv2_stage" "fail_missing_format" {
  expect_failure = true
  attrs = {
    api_id = "abc123xyz"
    name = "testing"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigateway/my-api"
      }
    ]
  }
}

# Test 5: FAIL - Empty access_log_settings block
resource "aws_apigatewayv2_stage" "fail_empty_access_log_settings" {
  expect_failure = true
  attrs = {
    api_id = "abc123xyz"
    name = "qa"
    access_log_settings = []
  }
}

# Test 6: PASS - HTTP API with complete access logging
resource "aws_apigatewayv2_stage" "pass_http_api_with_logging" {
  attrs = {
    api_id = "http123"
    name = "prod"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:eu-west-1:987654321098:log-group:/aws/apigateway/http-api"
        format = "$context.requestId $context.routeKey $context.status"
      }
    ]
    auto_deploy = true
  }
}

# Test 7: PASS - WebSocket API with complete access logging
resource "aws_apigatewayv2_stage" "pass_websocket_api_with_logging" {
  attrs = {
    api_id = "ws456"
    name = "production"
    access_log_settings = [
      {
        destination_arn = "arn:aws:logs:ap-southeast-1:111222333444:log-group:/aws/apigateway/websocket"
        format = "$context.connectionId $context.requestId $context.eventType"
      }
    ]
    deployment_id = "deploy123"
  }
}