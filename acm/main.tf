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

resource "aws_acm_certificate" "example" {
  domain_name       = "example.com"
  validation_method = "DNS"

  key_algorithm = "RSA_2048"

  tags = {
    Environment = "test"
  }
}

resource "aws_acmpca_certificate_authority" "example" {
  type    = "ROOT"
  enabled = false

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "example.com"
    }
  }

  tags = {
    Environment = "test"
  }
}
