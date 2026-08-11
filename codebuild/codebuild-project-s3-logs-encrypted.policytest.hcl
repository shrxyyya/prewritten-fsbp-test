# Copyright IBM Corp. 2026

policytest {
  targets = [
    "codebuild-project-s3-logs-encrypted.policy.hcl"
  ]
}
# Test 1: Pass - S3 logs enabled with encryption_disabled not set (defaults to false)
resource "aws_codebuild_project" "s3_logs_enabled_encryption_default" {
  attrs = {
    name = "test-project-1"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    logs_config = [{
      s3_logs = [{
        status = "ENABLED"
        location = "my-bucket/build-logs"
      }]
    }]
  }
}

# Test 2: Pass - S3 logs enabled with encryption_disabled explicitly set to false
resource "aws_codebuild_project" "s3_logs_enabled_encryption_explicit_false" {
  attrs = {
    name = "test-project-2"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    logs_config = [{
      s3_logs = [{
        status = "ENABLED"
        location = "my-bucket/build-logs"
        encryption_disabled = false
      }]
    }]
  }
}

# Test 3: Fail - S3 logs enabled with encryption_disabled set to true
resource "aws_codebuild_project" "s3_logs_enabled_encryption_disabled" {
  expect_failure = true
  attrs = {
    name = "test-project-3"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    logs_config = [{
      s3_logs = [{
        status = "ENABLED"
        location = "my-bucket/build-logs"
        encryption_disabled = true
      }]
    }]
  }
}

# Test 4: Pass - S3 logs disabled
resource "aws_codebuild_project" "s3_logs_disabled" {
  attrs = {
    name = "test-project-4"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    logs_config = [{
      s3_logs = [{
        status = "DISABLED"
      }]
    }]
  }
}

# Test 5: Pass - No logs_config block
resource "aws_codebuild_project" "no_logs_config" {
  attrs = {
    name = "test-project-5"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
  }
}

# Test 6: Pass - logs_config present but no s3_logs block
resource "aws_codebuild_project" "logs_config_no_s3_logs" {
  attrs = {
    name = "test-project-6"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    environment = [{
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      type = "LINUX_CONTAINER"
    }]
    source = [{
      type = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    logs_config = [{
      cloudwatch_logs = [{
        status = "ENABLED"
      }]
    }]
  }
}