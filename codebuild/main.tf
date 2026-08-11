terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "codebuild" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_kms_key" "codebuild" {
  description             = "KMS key for CodeBuild report group encryption"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "codebuild_reports" {
  bucket = "example-codebuild-reports"
}

resource "aws_codebuild_project" "example" {
  name         = "example-project"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    # codebuild-project-envvar-awscred-check: no PLAINTEXT AWS_ACCESS_KEY_ID /
    # AWS_SECRET_ACCESS_KEY variables; use PARAMETER_STORE instead
    environment_variable {
      name  = "EXAMPLE_PARAM"
      value = "/example/param"
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type     = "NO_SOURCE"
    buildspec = "version: 0.2\nphases:\n  build:\n    commands:\n      - echo hello"
  }

  # codebuild-project-logging-enabled: CloudWatch logging enabled (default status is ENABLED)
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    # codebuild-project-s3-logs-encrypted: S3 logs with encryption not disabled
    s3_logs {
      status             = "ENABLED"
      location           = "${aws_s3_bucket.codebuild_reports.id}/build-logs"
      encryption_disabled = false
    }
  }
}

resource "aws_codebuild_report_group" "example" {
  name = "example-report-group"

  # codebuild-report-group-encrypted-at-rest: S3 export with KMS key, encryption enabled
  export_config {
    type = "S3"

    s3_destination {
      bucket             = aws_s3_bucket.codebuild_reports.id
      encryption_key     = aws_kms_key.codebuild.arn
      encryption_disabled = false
    }
  }
}
