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

resource "aws_subnet" "example" {
  vpc_id                  = "vpc-12345678"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_emr_security_configuration" "example" {
  name = "example-emr-security-config"

  configuration = jsonencode({
    EncryptionConfiguration = {
      EnableAtRestEncryption = true
      EnableInTransitEncryption = true
    }
  })
}

resource "aws_emr_block_public_access_configuration" "example" {
  block_public_security_group_rules = true
}

resource "aws_emr_cluster" "example" {
  name          = "example-emr-cluster"
  release_label = "emr-7.0.0"
  applications  = ["Spark"]

  ec2_attributes {
    subnet_id = aws_subnet.example.id
  }

  security_configuration = aws_emr_security_configuration.example.name

  service_role = "EMR_DefaultRole"
}
