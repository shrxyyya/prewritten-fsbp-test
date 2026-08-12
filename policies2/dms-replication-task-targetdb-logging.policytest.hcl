# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-replication-task-targetdb-logging.policy.hcl"
  ]
}

# Pass case: Logging enabled with both TARGET_APPLY and TARGET_LOAD at LOGGER_SEVERITY_DEFAULT
resource "aws_dms_replication_task" "pass_with_default_severity" {
  attrs = {
    replication_task_id = "test-task"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Pass case: Logging enabled with LOGGER_SEVERITY_DEBUG
resource "aws_dms_replication_task" "pass_with_debug_severity" {
  attrs = {
    replication_task_id = "test-task-debug"
    migration_type = "cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEBUG\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEBUG\"}]}}"
  }
}

# Pass case: Logging enabled with LOGGER_SEVERITY_DETAILED_DEBUG
resource "aws_dms_replication_task" "pass_with_detailed_debug_severity" {
  attrs = {
    replication_task_id = "test-task-detailed"
    migration_type = "full-load"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DETAILED_DEBUG\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DETAILED_DEBUG\"}]}}"
  }
}

# Fail case: Logging disabled
resource "aws_dms_replication_task" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-no-logging"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":false,\"LogComponents\":[]}}"
  }
}

# Fail case: Missing TARGET_APPLY component
resource "aws_dms_replication_task" "fail_missing_target_apply" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-no-apply"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Fail case: Missing TARGET_LOAD component
resource "aws_dms_replication_task" "fail_missing_target_load" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-no-load"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Fail case: Invalid severity for TARGET_APPLY
resource "aws_dms_replication_task" "fail_invalid_target_apply_severity" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-invalid-apply"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_INFO\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Fail case: Invalid severity for TARGET_LOAD
resource "aws_dms_replication_task" "fail_invalid_target_load_severity" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-invalid-load"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_WARNING\"}]}}"
  }
}

# Fail case: No replication_task_settings configured
resource "aws_dms_replication_task" "fail_no_settings" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-no-settings"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
  }
}

# Fail case: Empty LogComponents array
resource "aws_dms_replication_task" "fail_empty_log_components" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-empty"
    migration_type = "full-load-and-cdc"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABC123"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    table_mappings = "{\"rules\":[]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[]}}"
  }
}
