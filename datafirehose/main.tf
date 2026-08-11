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

resource "aws_s3_bucket" "firehose_destination" {
  bucket = "example-firehose-destination"
}

resource "aws_iam_role" "firehose" {
  name = "firehose-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
    }]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = "example-delivery-stream"
  destination = "extended_s3"

  # kinesis-firehose-delivery-stream-encrypted: SSE must be enabled
  # (filter excludes streams with kinesis_source_configuration)
  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.firehose_destination.arn
  }
}
