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

resource "aws_athena_workgroup" "example" {
  name = "example-workgroup"

  configuration {
    # athena-workgroup-logging-enabled: publish CloudWatch metrics
    publish_cloudwatch_metrics_enabled = true
  }
}
