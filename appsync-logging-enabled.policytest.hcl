# Copyright IBM Corp. 2026

policytest {
  targets = [
    "appsync-logging-enabled.policy.hcl"
  ]
}
# Scenario 1: Valid ERROR log level with CloudWatch role (PASS)
resource "aws_appsync_graphql_api" "valid_error_logging" {
  attrs = {
    name = "test-api"
    authentication_type = "API_KEY"
    log_config = [
      {
        field_log_level = "ERROR"
        cloudwatch_logs_role_arn = "arn:aws:iam::123456789012:role/appsync-logs-role"
        exclude_verbose_content = false
      }
    ]
  }
}

# Scenario 2: Valid ALL log level with CloudWatch role (PASS)
resource "aws_appsync_graphql_api" "valid_all_logging" {
  attrs = {
    name = "test-api-all"
    authentication_type = "AWS_IAM"
    log_config = [
      {
        field_log_level = "ALL"
        cloudwatch_logs_role_arn = "arn:aws:iam::123456789012:role/appsync-logs-role"
        exclude_verbose_content = true
      }
    ]
  }
}

# Scenario 3: NONE log level (FAIL)
resource "aws_appsync_graphql_api" "invalid_none_logging" {
  expect_failure = true
  attrs = {
    name = "test-api-none"
    authentication_type = "API_KEY"
    log_config = [
      {
        field_log_level = "NONE"
        cloudwatch_logs_role_arn = "arn:aws:iam::123456789012:role/appsync-logs-role"
      }
    ]
  }
}

# Scenario 4: Missing log_config block (FAIL)
resource "aws_appsync_graphql_api" "missing_log_config" {
  expect_failure = true
  attrs = {
    name = "test-api-no-config"
    authentication_type = "API_KEY"
  }
}

# Scenario 5: Valid log level but missing CloudWatch role (FAIL)
resource "aws_appsync_graphql_api" "missing_cloudwatch_role" {
  expect_failure = true
  attrs = {
    name = "test-api-no-role"
    authentication_type = "AWS_IAM"
    log_config = [
      {
        field_log_level = "ERROR"
        cloudwatch_logs_role_arn = ""
      }
    ]
  }
}

# Scenario 6: INFO log level (FAIL - INFO is not a valid AppSync field_log_level)
resource "aws_appsync_graphql_api" "info_log_level" {
  expect_failure = true
  attrs = {
    name = "test-api-info"
    authentication_type = "API_KEY"
    log_config = [
      {
        field_log_level = "INFO"
        cloudwatch_logs_role_arn = "arn:aws:iam::123456789012:role/appsync-logs-role"
      }
    ]
  }
}

# Scenario 7: Empty log_config block (FAIL)
resource "aws_appsync_graphql_api" "empty_log_config" {
  expect_failure = true
  attrs = {
    name = "test-api-empty"
    authentication_type = "API_KEY"
    log_config = [
      {
      }
    ]
  }
}