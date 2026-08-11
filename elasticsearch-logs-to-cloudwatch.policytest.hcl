# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-logs-to-cloudwatch.policy.hcl"
    ]
}

# Test 1: PASS - Domain with ES_APPLICATION_LOGS and CloudWatch log group ARN (enabled defaults to true)
resource "aws_elasticsearch_domain" "pass_with_default_enabled" {
  attrs = {
    domain_name = "compliant-domain"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/compliant-domain"
      }
    ]
  }
}

# Test 2: PASS - Domain with explicitly enabled=true
resource "aws_elasticsearch_domain" "pass_with_explicit_enabled_true" {
  attrs = {
    domain_name = "compliant-explicit-domain"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/compliant-explicit"
      }
    ]
  }
}

# Test 3: PASS - Domain with multiple log types including ES_APPLICATION_LOGS
resource "aws_elasticsearch_domain" "pass_with_multiple_log_types" {
  attrs = {
    domain_name = "multiple-logs-domain"
    log_publishing_options = [
      {
        log_type = "INDEX_SLOW_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/index-slow"
      },
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/application"
      },
      {
        log_type = "SEARCH_SLOW_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/search-slow"
      }
    ]
  }
}

# Test 4: SKIP - Domain without log_publishing_options (filtered out by policy)
resource "aws_elasticsearch_domain" "skip_no_log_publishing_options" {
  attrs = {
    domain_name = "no-logs-domain"
    elasticsearch_version = "7.10"
  }
}

# Test 5: FAIL - Domain with log_publishing_options but no ES_APPLICATION_LOGS
resource "aws_elasticsearch_domain" "fail_missing_es_application_logs" {
  expect_failure = true
  attrs = {
    domain_name = "missing-app-logs-domain"
    log_publishing_options = [
      {
        log_type = "INDEX_SLOW_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/index-slow"
      }
    ]
  }
}

# Test 6: FAIL -  Domain with ES_APPLICATION_LOGS but enabled=false
resource "aws_elasticsearch_domain" "fail_disabled_logging" {
  expect_failure = true
  attrs = {
    domain_name = "disabled-logs-domain"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = false
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/disabled"
      }
    ]
  }
}

# Test 7: FAIL - Domain with ES_APPLICATION_LOGS but missing cloudwatch_log_group_arn
resource "aws_elasticsearch_domain" "fail_missing_log_group_arn" {
  expect_failure = true
  attrs = {
    domain_name = "missing-arn-domain"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
      }
    ]
  }
}

# Test 8: FAIL - Domain with ES_APPLICATION_LOGS but empty cloudwatch_log_group_arn
resource "aws_elasticsearch_domain" "fail_empty_log_group_arn" {
  expect_failure = true
  attrs = {
    domain_name = "empty-arn-domain"
    log_publishing_options = [
      {
        log_type = "ES_APPLICATION_LOGS"
        enabled = true
        cloudwatch_log_group_arn = ""
      }
    ]
  }
}