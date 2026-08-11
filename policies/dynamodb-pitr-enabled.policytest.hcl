# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dynamodb-pitr-enabled.policy.hcl"
  ]
}

# Test 1: PASS - DynamoDB table with PITR explicitly enabled
resource "aws_dynamodb_table" "pass_pitr_explicitly_enabled" {
  attrs = {
    name           = "compliant-table"
    hash_key       = "id"
    billing_mode   = "PAY_PER_REQUEST"
    
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
    
    point_in_time_recovery = [
      {
        enabled = true
      }
    ]
  }
}

# Test 2: FAIL - DynamoDB table with PITR explicitly disabled
resource "aws_dynamodb_table" "fail_pitr_explicitly_disabled" {
  expect_failure = true
  
  attrs = {
    name           = "non-compliant-table"
    hash_key       = "id"
    billing_mode   = "PAY_PER_REQUEST"
    
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
    
    point_in_time_recovery = [
      {
        enabled = false
      }
    ]
  }
}

# Test 3: FAIL - DynamoDB table without point_in_time_recovery block
resource "aws_dynamodb_table" "fail_pitr_block_missing" {
  expect_failure = true
  
  attrs = {
    name           = "no-pitr-table"
    hash_key       = "id"
    billing_mode   = "PAY_PER_REQUEST"
    
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

# Test 4: FAIL - DynamoDB table with empty point_in_time_recovery block (enabled missing)
resource "aws_dynamodb_table" "fail_pitr_enabled_attribute_missing" {
  expect_failure = true
  
  attrs = {
    name           = "incomplete-pitr-table"
    hash_key       = "id"
    billing_mode   = "PAY_PER_REQUEST"
    
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
    
    point_in_time_recovery = [
      {
        # enabled attribute is missing - should default to false
      }
    ]
  }
}