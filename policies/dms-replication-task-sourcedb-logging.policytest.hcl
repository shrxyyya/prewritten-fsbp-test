# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-replication-task-sourcedb-logging.policy.hcl"
  ]
}

# NOTE: Due to tfpolicy limitations (no JSON parsing, no string pattern matching),
# this policy can only validate that replication_task_settings is defined.
# Full validation requires AWS Config rule or Sentinel policy.

# Pass Case 1: Task with replication_task_settings defined
resource "aws_dms_replication_task" "pass_with_settings" {
  attrs = {
    replication_task_id = "test-task-with-settings"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABCDEFGHIJKLMNOP"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    migration_type = "full-load-and-cdc"
    table_mappings = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
    replication_task_settings = "{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]}}"
  }
}

# Pass Case 2: Task with minimal settings (policy cannot validate content)
resource "aws_dms_replication_task" "pass_with_minimal_settings" {
  attrs = {
    replication_task_id = "test-task-minimal"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABCDEFGHIJKLMNOP"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    migration_type = "cdc"
    table_mappings = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
    replication_task_settings = "{\"TargetMetadata\":{\"TargetSchema\":\"\"}}"
  }
}

# Fail Case: Task without replication_task_settings
resource "aws_dms_replication_task" "fail_no_settings" {
  expect_failure = true
  attrs = {
    replication_task_id = "test-task-no-settings"
    replication_instance_arn = "arn:aws:dms:us-east-1:123456789012:rep:ABCDEFGHIJKLMNOP"
    source_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:SOURCE"
    target_endpoint_arn = "arn:aws:dms:us-east-1:123456789012:endpoint:TARGET"
    migration_type = "full-load"
    table_mappings = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  }
}
