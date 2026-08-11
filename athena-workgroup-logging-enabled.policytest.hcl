# Copyright IBM Corp. 2026

policytest {
    targets = [
        "athena-workgroup-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - CloudWatch metrics publishing is enabled
resource "aws_athena_workgroup" "pass_logging_enabled" {
  attrs = {
    name = "athena-workgroup-logging-enabled"
    configuration = [
        {
            publish_cloudwatch_metrics_enabled = true
        }
    ]
  }
}

# Test 2: FAIL - CloudWatch metrics publishing is disabled
resource "aws_athena_workgroup" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    name = "athena-workgroup-logging-disabled"
    configuration = [
        {
            publish_cloudwatch_metrics_enabled = false
        }
    ]
  }
}

# Test 3: PASS - Missing publish_cloudwatch_metrics_enabled defaults to true
resource "aws_athena_workgroup" "pass_logging_missing_flag" {
  attrs = {
    name = "athena-workgroup-logging-missing-flag"
    configuration = [
        {}
    ]
  }
}

# Test 4: PASS - Missing configuration defaults to true
resource "aws_athena_workgroup" "pass_logging_missing_configuration" {
  attrs = {
    name = "athena-workgroup-logging-missing-config"
  }
}

