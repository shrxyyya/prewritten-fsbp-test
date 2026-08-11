# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-replication-not-public.policy.hcl"
  ]
}

# Test 1: Pass - publicly_accessible explicitly set to false
resource "aws_dms_replication_instance" "pass_explicit_false" {
  attrs = {
    replication_instance_id    = "test-replication-instance"
    replication_instance_class = "dms.t3.micro"
    publicly_accessible        = false
    allocated_storage          = 50
  }
}

# Test 2: Pass - publicly_accessible not specified (defaults to false)
resource "aws_dms_replication_instance" "pass_default_false" {
  attrs = {
    replication_instance_id    = "test-replication-instance-default"
    replication_instance_class = "dms.t3.micro"
    allocated_storage          = 50
  }
}

# Test 3: Fail - publicly_accessible set to true
resource "aws_dms_replication_instance" "fail_public_instance" {
  expect_failure = true
  attrs = {
    replication_instance_id    = "test-public-instance"
    replication_instance_class = "dms.t3.micro"
    publicly_accessible        = true
    allocated_storage          = 50
  }
}