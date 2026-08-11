# Copyright IBM Corp. 2026

policytest {
  targets = [
    "codebuild-project-envvar-awscred-check.policy.hcl"
  ]
}

# Test 1: FAIL - AWS_ACCESS_KEY_ID as plaintext (no type specified, defaults to PLAINTEXT)
resource "aws_codebuild_project" "fail_plaintext_access_key_no_type" {
  expect_failure = true
  attrs = {
    name = "test-project-1"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_ACCESS_KEY_ID"
            value = "AKIAIOSFODNN7EXAMPLE"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - AWS_SECRET_ACCESS_KEY as plaintext (no type specified)
resource "aws_codebuild_project" "fail_plaintext_secret_key_no_type" {
  expect_failure = true
  attrs = {
    name = "test-project-2"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_SECRET_ACCESS_KEY"
            value = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Both credentials as plaintext
resource "aws_codebuild_project" "fail_both_plaintext_credentials" {
  expect_failure = true
  attrs = {
    name = "test-project-3"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_ACCESS_KEY_ID"
            value = "AKIAIOSFODNN7EXAMPLE"
          },
          {
            name = "AWS_SECRET_ACCESS_KEY"
            value = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - AWS_ACCESS_KEY_ID explicitly set to PLAINTEXT type
resource "aws_codebuild_project" "fail_explicit_plaintext_access_key" {
  expect_failure = true
  attrs = {
    name = "test-project-4"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_ACCESS_KEY_ID"
            value = "AKIAIOSFODNN7EXAMPLE"
            type = "PLAINTEXT"
          }
        ]
      }
    ]
  }
}

# Test 5: PASS - AWS_ACCESS_KEY_ID stored in Parameter Store
resource "aws_codebuild_project" "pass_access_key_parameter_store" {
  attrs = {
    name = "test-project-5"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_ACCESS_KEY_ID"
            value = "/codebuild/aws_access_key_id"
            type = "PARAMETER_STORE"
          }
        ]
      }
    ]
  }
}

# Test 6: PASS - AWS_SECRET_ACCESS_KEY stored in Secrets Manager
resource "aws_codebuild_project" "pass_secret_key_secrets_manager" {
  attrs = {
    name = "test-project-6"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_SECRET_ACCESS_KEY"
            value = "arn:aws:secretsmanager:us-east-1:123456789012:secret:codebuild/secret-key"
            type = "SECRETS_MANAGER"
          }
        ]
      }
    ]
  }
}

# Test 7: PASS - Both credentials stored securely
resource "aws_codebuild_project" "pass_both_credentials_secure" {
  attrs = {
    name = "test-project-7"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "AWS_ACCESS_KEY_ID"
            value = "/codebuild/aws_access_key_id"
            type = "PARAMETER_STORE"
          },
          {
            name = "AWS_SECRET_ACCESS_KEY"
            value = "arn:aws:secretsmanager:us-east-1:123456789012:secret:codebuild/secret-key"
            type = "SECRETS_MANAGER"
          }
        ]
      }
    ]
  }
}

# Test 8: PASS - No environment variables (filtered out)
resource "aws_codebuild_project" "pass_no_environment_variables" {
  attrs = {
    name = "test-project-8"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
      }
    ]
  }
}

# Test 9: PASS - Other environment variables but no AWS credentials
resource "aws_codebuild_project" "pass_other_env_vars_no_credentials" {
  attrs = {
    name = "test-project-9"
    environment = [
      {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:5.0"
        type = "LINUX_CONTAINER"
        environment_variable = [
          {
            name = "BUILD_ENV"
            value = "production"
            type = "PLAINTEXT"
          },
          {
            name = "LOG_LEVEL"
            value = "INFO"
          }
        ]
      }
    ]
  }
}