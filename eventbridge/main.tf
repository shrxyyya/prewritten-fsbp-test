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

resource "aws_cloudwatch_event_bus" "example" {
  name = "example-bus"
}

resource "aws_cloudwatch_event_bus_policy" "example" {
  event_bus_name = aws_cloudwatch_event_bus.example.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEvents"
        Effect    = "Allow"
        Principal = {
          AWS = "123456789012"
        }
        Action   = "events:PutEvents"
        Resource = aws_cloudwatch_event_bus.example.arn
      }
    ]
  })
}
