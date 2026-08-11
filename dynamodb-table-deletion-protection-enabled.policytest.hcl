# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dynamodb-table-deletion-protection-enabled.policy.hcl"
    ]
}

resource "aws_dynamodb_table" "compliant" {
  attrs = {
    name                        = "compliant-table"
    hash_key                    = "id"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = true
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

resource "aws_dynamodb_table" "non_compliant_explicit" {
  expect_failure = true
  attrs = {
    name                        = "non-compliant-table"
    hash_key                    = "id"
    billing_mode                = "PAY_PER_REQUEST"
    deletion_protection_enabled = false
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}

resource "aws_dynamodb_table" "non_compliant_default" {
  expect_failure = true
  attrs = {
    name         = "default-table"
    hash_key     = "id"
    billing_mode = "PAY_PER_REQUEST"
    attribute = [
      {
        name = "id"
        type = "S"
      }
    ]
  }
}