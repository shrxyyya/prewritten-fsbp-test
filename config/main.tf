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

resource "aws_s3_bucket" "config" {
  bucket = "example-aws-config-delivery"
}

resource "aws_config_configuration_recorder" "example" {
  name     = "example-recorder"

  # config1-aws-config-enabled: service-linked role ARN
  role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"

  # config1-aws-config-enabled: record all resources including global IAM resources
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "example" {
  name = aws_config_configuration_recorder.example.name

  # config1-aws-config-enabled: recorder must be enabled
  is_enabled = true

  depends_on = [aws_config_delivery_channel.example]
}

resource "aws_config_delivery_channel" "example" {
  name = "example-delivery-channel"

  # config1-aws-config-enabled: S3 bucket must be specified
  s3_bucket_name = aws_s3_bucket.config.id

  depends_on = [aws_config_configuration_recorder.example]
}
