# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-audit-logging-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Audit logging fully configured with enabled=true
resource "aws_elasticsearch_domain" "pass_fully_configured" {
  attrs = {
    domain_name = "compliant-domain"
    log_publishing_options = [
      {
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/audit"
      }
    ]
  }
}

# Test 2: PASS - Audit logging with enabled not specified (defaults to true)
resource "aws_elasticsearch_domain" "pass_enabled_default" {
  attrs = {
    domain_name = "default-enabled-domain"
    log_publishing_options = [
      {
        log_type                 = "AUDIT_LOGS"
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/audit"
      }
    ]
  }
}

# Test 3: PASS - Multiple log types including AUDIT_LOGS
resource "aws_elasticsearch_domain" "pass_multiple_log_types" {
  attrs = {
    domain_name = "multiple-logs-domain"
    log_publishing_options = [
      {
        log_type                 = "ES_APPLICATION_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/application"
      },
      {
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/audit"
      }
    ]
  }
}

# Test 4: FAIL - Only other log types, no AUDIT_LOGS
resource "aws_elasticsearch_domain" "fail_no_audit_logs" {
  expect_failure = true
  attrs = {
    domain_name = "no-audit-domain"
    log_publishing_options = [
      {
        log_type                 = "ES_APPLICATION_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/application"
      },
      {
        log_type                 = "SEARCH_SLOW_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/search"
      }
    ]
  }
}

# Test 5: FAIL - AUDIT_LOGS with enabled=false
resource "aws_elasticsearch_domain" "fail_audit_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "disabled-audit-domain"
    log_publishing_options = [
      {
        log_type                 = "AUDIT_LOGS"
        enabled                  = false
        cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/elasticsearch/audit"
      }
    ]
  }
}

# Test 6: FAIL - AUDIT_LOGS without cloudwatch_log_group_arn
resource "aws_elasticsearch_domain" "fail_no_log_group_arn" {
  expect_failure = true
  attrs = {
    domain_name = "no-arn-domain"
    log_publishing_options = [
      {
        log_type = "AUDIT_LOGS"
        enabled  = true
      }
    ]
  }
}

# Test 7: FAIL - AUDIT_LOGS with empty cloudwatch_log_group_arn
resource "aws_elasticsearch_domain" "fail_empty_log_group_arn" {
  expect_failure = true
  attrs = {
    domain_name = "empty-arn-domain"
    log_publishing_options = [
      {
        log_type                 = "AUDIT_LOGS"
        enabled                  = true
        cloudwatch_log_group_arn = ""
      }
    ]
  }
}
