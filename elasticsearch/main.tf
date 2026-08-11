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

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/aes/example"
}

resource "aws_subnet" "example_a" {
  vpc_id     = "vpc-12345678"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "example_b" {
  vpc_id     = "vpc-12345678"
  cidr_block = "10.0.2.0/24"
}

resource "aws_elasticsearch_domain" "example" {
  domain_name           = "example-domain"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type            = "m5.large.elasticsearch"
    instance_count           = 3
    dedicated_master_enabled = true
    dedicated_master_count   = 3
    dedicated_master_type    = "m5.large.elasticsearch"
    zone_awareness_enabled   = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"
  }

  vpc_options {
    subnet_ids = [aws_subnet.example_a.id, aws_subnet.example_b.id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.example.arn
    log_type                 = "ES_APPLICATION_LOGS"
    enabled                  = true
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.example.arn
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
  }
}
