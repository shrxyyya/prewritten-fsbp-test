# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-neptune-iam-authorization-enabled.policy.hcl"
  ]
}

# Test 1: PASS - Neptune endpoint with valid IAM role ARN
resource "aws_dms_endpoint" "neptune_compliant" {
  attrs = {
    endpoint_id          = "neptune-endpoint-compliant"
    endpoint_type        = "target"
    engine_name          = "neptune"
    service_access_role  = "arn:aws:iam::123456789012:role/dms-neptune-access-role"
    server_name          = "neptune-cluster.cluster-abc123.us-east-1.neptune.amazonaws.com"
    port                 = 8182
    ssl_mode             = "require"
  }
}

# Test 2: FAIL - Neptune endpoint without service_access_role (null)
resource "aws_dms_endpoint" "neptune_no_iam" {
  expect_failure = true
  attrs = {
    endpoint_id   = "neptune-endpoint-no-iam"
    endpoint_type = "target"
    engine_name   = "neptune"
    server_name   = "neptune-cluster.cluster-xyz789.us-west-2.neptune.amazonaws.com"
    port          = 8182
  }
}

# Test 3: FAIL - Neptune endpoint with empty service_access_role
resource "aws_dms_endpoint" "neptune_empty_role" {
  expect_failure = true
  attrs = {
    endpoint_id          = "neptune-endpoint-empty-role"
    endpoint_type        = "target"
    engine_name          = "neptune"
    service_access_role  = ""
    server_name          = "neptune-cluster.cluster-def456.eu-west-1.neptune.amazonaws.com"
    port                 = 8182
  }
}

# Test 4: PASS - Neptune endpoint with any non-empty service_access_role
# Note: Policy validates presence, not ARN format
resource "aws_dms_endpoint" "neptune_any_role" {
  attrs = {
    endpoint_id          = "neptune-endpoint-any-role"
    endpoint_type        = "target"
    engine_name          = "neptune"
    service_access_role  = "some-role-identifier"
    server_name          = "neptune-cluster.cluster-ghi789.ap-south-1.neptune.amazonaws.com"
    port                 = 8182
  }
}

# Test 5: PASS (filtered out) - Non-Neptune endpoint (MySQL)
resource "aws_dms_endpoint" "mysql_endpoint" {
  attrs = {
    endpoint_id   = "mysql-endpoint"
    endpoint_type = "source"
    engine_name   = "mysql"
    server_name   = "mysql-db.example.com"
    port          = 3306
    username      = "admin"
  }
}

# Test 6: PASS - Neptune endpoint with long valid IAM role ARN
resource "aws_dms_endpoint" "neptune_long_arn" {
  attrs = {
    endpoint_id          = "neptune-endpoint-long-arn"
    endpoint_type        = "target"
    engine_name          = "neptune"
    service_access_role  = "arn:aws:iam::987654321098:role/service-role/dms-neptune-database-access-role-with-long-name"
    server_name          = "neptune-prod.cluster-abcdefgh.us-east-1.neptune.amazonaws.com"
    port                 = 8182
    ssl_mode             = "verify-full"
    kms_key_arn          = "arn:aws:kms:us-east-1:987654321098:key/12345678-1234-1234-1234-123456789012"
  }
}