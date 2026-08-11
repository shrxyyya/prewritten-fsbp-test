# Copyright IBM Corp. 2026

policytest {
  targets = [
    "cloudformation-stack-service-role-check.policy.hcl"
  ]
}
# Pass case: Stack with valid IAM role ARN
resource "aws_cloudformation_stack" "pass_with_valid_iam_role" {
  attrs = {
    name         = "compliant-stack"
    iam_role_arn = "arn:aws:iam::123456789012:role/CloudFormationServiceRole"
    template_body = "{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Resources\":{}}"
  }
}

# Fail case: Stack without iam_role_arn attribute
resource "aws_cloudformation_stack" "fail_without_iam_role" {
  expect_failure = true
  attrs = {
    name = "non-compliant-stack"
    template_body = "{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Resources\":{}}"
  }
}

# Fail case: Stack with empty string for iam_role_arn
resource "aws_cloudformation_stack" "fail_with_empty_iam_role" {
  expect_failure = true
  attrs = {
    name         = "empty-role-stack"
    iam_role_arn = ""
    template_body = "{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Resources\":{}}"
  }
}

# Fail case: Stack with null iam_role_arn
resource "aws_cloudformation_stack" "fail_with_null_iam_role" {
  expect_failure = true
  attrs = {
    name         = "null-role-stack"
    iam_role_arn = null
    template_body = "{\"AWSTemplateFormatVersion\":\"2010-09-09\",\"Resources\":{}}"
  }
}
