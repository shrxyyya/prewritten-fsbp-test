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

resource "aws_iam_role" "appsync_logs" {
  name = "appsync-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "appsync.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "appsync_logs" {
  role       = aws_iam_role.appsync_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
}

resource "aws_appsync_graphql_api" "example" {
  name = "example-graphql-api"

  # appsync-authorization-check: must not use API_KEY
  authentication_type = "AWS_IAM"

  # appsync-logging-enabled: field-level logging with CloudWatch role
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_logs.arn
    field_log_level          = "ERROR"
  }
}
