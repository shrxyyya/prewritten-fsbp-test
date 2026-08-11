# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dynamodb-autoscaling-enabled.policy.hcl"
  ]
}

# Test 1: PASS - On-demand billing mode (PAY_PER_REQUEST)
resource "aws_dynamodb_table" "on_demand_table" {
  attrs = {
    name = "on-demand-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

# Test 2: PASS - Provisioned billing mode is allowed
resource "aws_dynamodb_table" "provisioned_table" {
  attrs = {
    name = "provisioned-table"
    billing_mode = "PROVISIONED"
    read_capacity = 5
    write_capacity = 5
    hash_key = "id"
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

# Test 3: PASS - Default billing mode resolves to PROVISIONED
resource "aws_dynamodb_table" "default_billing" {
  attrs = {
    name = "default-billing-table"
    read_capacity = 5
    write_capacity = 5
    hash_key = "id"
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

# Test 4: PASS - Unsupported billing_mode value (filtered out; policy only evaluates PROVISIONED tables)
resource "aws_dynamodb_table" "invalid_billing_mode" {
  attrs = {
    name = "invalid-billing-mode-table"
    billing_mode = "INVALID"
    hash_key = "id"
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}
