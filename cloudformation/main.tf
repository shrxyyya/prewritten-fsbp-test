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

resource "aws_iam_role" "cloudformation_service" {
  name = "cloudformation-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudformation.amazonaws.com" }
    }]
  })
}

resource "aws_cloudformation_stack" "example" {
  name = "example-stack"

  # cloudformation-stack-service-role-check: must have an IAM service role
  iam_role_arn = aws_iam_role.cloudformation_service.arn

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Resources = {
      WaitHandle = {
        Type = "AWS::CloudFormation::WaitConditionHandle"
      }
    }
  })
}
