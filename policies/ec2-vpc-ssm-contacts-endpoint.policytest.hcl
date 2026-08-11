# Copyright IBM Corp. 2026

policytest {
  targets = ["ec2-vpc-ssm-contacts-endpoint.policy.hcl"]
}

# Test 1: PASS - VPC with Interface endpoint for ssm-contacts in us-east-1
resource "aws_vpc" "pass_us_east_1" {
  attrs = {
    id                   = "vpc-12345678"
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "pass_ssm_contacts_us_east_1" {
  skip = true
  attrs = {
    vpc_id            = "vpc-12345678"
    service_name      = "com.amazonaws.us-east-1.ssm-contacts"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-abc123"]
  }
}

# Test 2: PASS - VPC with Interface endpoint for ssm-contacts in a different region
# (validates region-agnostic matching; would have failed under the old us-east-1 hardcode)
resource "aws_vpc" "pass_us_west_2" {
  attrs = {
    id                   = "vpc-33333333"
    cidr_block           = "10.4.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "pass_ssm_contacts_us_west_2" {
  skip = true
  attrs = {
    vpc_id            = "vpc-33333333"
    service_name      = "com.amazonaws.us-west-2.ssm-contacts"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-ghi789"]
  }
}

# Test 3: PASS - VPC with Interface endpoint for ssm-contacts in eu-west-1
resource "aws_vpc" "pass_eu_west_1" {
  attrs = {
    id                   = "vpc-44444444"
    cidr_block           = "10.5.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "pass_ssm_contacts_eu_west_1" {
  skip = true
  attrs = {
    vpc_id            = "vpc-44444444"
    service_name      = "com.amazonaws.eu-west-1.ssm-contacts"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-jkl012"]
  }
}

# Test 4: FAIL - VPC with no endpoints
resource "aws_vpc" "fail_no_endpoints" {
  expect_failure = true
  attrs = {
    id                   = "vpc-87654321"
    cidr_block           = "10.1.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

# Test 5: FAIL - VPC with Gateway-type endpoint (wrong type)
resource "aws_vpc" "fail_gateway_type" {
  expect_failure = true
  attrs = {
    id                   = "vpc-11111111"
    cidr_block           = "10.2.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "fail_gateway_endpoint" {
  skip = true
  attrs = {
    vpc_id            = "vpc-11111111"
    service_name      = "com.amazonaws.us-east-1.ssm-contacts"
    vpc_endpoint_type = "Gateway"
  }
}

# Test 6: FAIL - VPC with Interface endpoint for a different service (S3)
resource "aws_vpc" "fail_wrong_service" {
  expect_failure = true
  attrs = {
    id                   = "vpc-22222222"
    cidr_block           = "10.3.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "fail_s3_interface" {
  skip = true
  attrs = {
    vpc_id            = "vpc-22222222"
    service_name      = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-def456"]
  }
}

# Test 7: FAIL - VPC with Interface endpoint for ssm-incidents (related but different service)
resource "aws_vpc" "fail_ssm_incidents_only" {
  expect_failure = true
  attrs = {
    id                   = "vpc-66666666"
    cidr_block           = "10.7.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "fail_ssm_incidents_interface" {
  skip = true
  attrs = {
    vpc_id            = "vpc-66666666"
    service_name      = "com.amazonaws.us-east-1.ssm-incidents"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-mno345"]
  }
}

# Test 8: FAIL - second VPC in a multi-VPC scenario, missing the endpoint
resource "aws_vpc" "fail_multi_vpc_missing" {
  expect_failure = true
  attrs = {
    id                   = "vpc-55555555"
    cidr_block           = "10.6.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

# Test 9: PASS - FIPS variant (ssm-contacts-fips) is accepted
resource "aws_vpc" "pass_ssm_contacts_fips" {
  attrs = {
    id                   = "vpc-fips0001"
    cidr_block           = "10.8.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
  }
}

resource "aws_vpc_endpoint" "pass_ssm_contacts_fips_endpoint" {
  skip = true
  attrs = {
    vpc_id            = "vpc-fips0001"
    service_name      = "com.amazonaws.us-east-1.ssm-contacts-fips"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-fips0001"]
  }
}
