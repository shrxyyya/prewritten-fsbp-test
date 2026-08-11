# Copyright IBM Corp. 2026

policytest  {
  targets = [
    "codebuild-project-logging-enabled.policy.hcl"
  ]
}
# Pass case 1: CloudWatch Logs explicitly enabled
resource "aws_codebuild_project" "pass_cloudwatch_explicitly_enabled" {
  attrs = {
    name         = "test-project-cloudwatch"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{
      cloudwatch_logs = [{
        status = "ENABLED"
      }]
    }]
  }
}

# Pass case 2: S3 Logs explicitly enabled
resource "aws_codebuild_project" "pass_s3_explicitly_enabled" {
  attrs = {
    name         = "test-project-s3"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{
      s3_logs = [{
        status   = "ENABLED"
        location = "my-bucket/build-logs"
      }]
    }]
  }
}

# Pass case 3: Both CloudWatch and S3 Logs enabled
resource "aws_codebuild_project" "pass_both_enabled" {
  attrs = {
    name         = "test-project-both"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{
      cloudwatch_logs = [{
        status = "ENABLED"
      }]
      s3_logs = [{
        status   = "ENABLED"
        location = "my-bucket/build-logs"
      }]
    }]
  }
}

# Pass case 4: No logs_config block (CloudWatch defaults to ENABLED)
resource "aws_codebuild_project" "pass_no_logs_config_cloudwatch_default" {
  attrs = {
    name         = "test-project-no-logs-config"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
  }
}

# Pass case 5: Empty logs_config block (CloudWatch defaults to ENABLED)
resource "aws_codebuild_project" "pass_empty_logs_config" {
  attrs = {
    name         = "test-project-empty-logs-config"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{}]
  }
}

# Fail case 1: Both CloudWatch and S3 Logs explicitly disabled
resource "aws_codebuild_project" "fail_both_disabled" {
  expect_failure = true
  
  attrs = {
    name         = "test-project-both-disabled"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{
      cloudwatch_logs = [{
        status = "DISABLED"
      }]
      s3_logs = [{
        status = "DISABLED"
      }]
    }]
  }
}

# Fail case 2: CloudWatch disabled and S3 not configured (defaults to DISABLED)
resource "aws_codebuild_project" "fail_cloudwatch_disabled_s3_not_configured" {
  expect_failure = true
  
  attrs = {
    name         = "test-project-cloudwatch-disabled"
    service_role = "arn:aws:iam::123456789012:role/codebuild-role"
    
    artifacts = [{
      type = "NO_ARTIFACTS"
    }]
    
    environment = [{
      compute_type                = "BUILD_GENERAL1_SMALL"
      image                      = "aws/codebuild/standard:5.0"
      type                       = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
    }]
    
    source = [{
      type     = "GITHUB"
      location = "https://github.com/example/repo.git"
    }]
    
    logs_config = [{
      cloudwatch_logs = [{
        status = "DISABLED"
      }]
    }]
  }
}