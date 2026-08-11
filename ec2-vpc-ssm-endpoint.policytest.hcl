# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-vpc-ssm-endpoint.policy.hcl"
  ]
}

// Test 1: PASS - VPC with Interface SSM endpoint in us-east-1
resource "aws_vpc" "pass_us_east_1" {
  attrs = {
    id         = "vpc-12345678"
    cidr_block = "10.0.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ssm_us_east_1" {
  skip = true
  attrs = {
    vpc_id            = "vpc-12345678"
    service_name      = "com.amazonaws.us-east-1.ssm"
    vpc_endpoint_type = "Interface"
  }
}

// Test 2: PASS - VPC with Interface SSM endpoint in us-west-2 (region-agnostic)
resource "aws_vpc" "pass_us_west_2" {
  attrs = {
    id         = "vpc-22222222"
    cidr_block = "10.4.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ssm_us_west_2" {
  skip = true
  attrs = {
    vpc_id            = "vpc-22222222"
    service_name      = "com.amazonaws.us-west-2.ssm"
    vpc_endpoint_type = "Interface"
  }
}

// Test 3: PASS - VPC with multiple endpoints including the required SSM Interface
resource "aws_vpc" "pass_multi_endpoint_vpc" {
  attrs = {
    id         = "vpc-55555555"
    cidr_block = "10.3.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_multi_s3_gateway" {
  skip = true
  attrs = {
    vpc_id            = "vpc-55555555"
    service_name      = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
  }
}

resource "aws_vpc_endpoint" "pass_multi_ssm_interface" {
  skip = true
  attrs = {
    vpc_id            = "vpc-55555555"
    service_name      = "com.amazonaws.us-east-1.ssm"
    vpc_endpoint_type = "Interface"
  }
}

// Test 4: FAIL - VPC without any endpoints
resource "aws_vpc" "fail_no_endpoints" {
  expect_failure = true
  attrs = {
    id         = "vpc-87654321"
    cidr_block = "10.1.0.0/16"
  }
}

// Test 5: FAIL - VPC with only a non-SSM Gateway endpoint
resource "aws_vpc" "fail_wrong_service" {
  expect_failure = true
  attrs = {
    id         = "vpc-11111111"
    cidr_block = "10.2.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_s3_gateway" {
  skip = true
  attrs = {
    vpc_id            = "vpc-11111111"
    service_name      = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
  }
}

// Test 6: FAIL - VPC where the SSM endpoint is Gateway type (must be Interface)
resource "aws_vpc" "fail_gateway_type" {
  expect_failure = true
  attrs = {
    id         = "vpc-44444444"
    cidr_block = "10.5.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ssm_gateway" {
  skip = true
  attrs = {
    vpc_id            = "vpc-44444444"
    service_name      = "com.amazonaws.eu-west-1.ssm"
    vpc_endpoint_type = "Gateway"
  }
}

// Test 7: FAIL - VPC with only related-but-different SSM-family services.
// 'ssm-contacts', 'ssm-incidents', and 'ssmmessages' must NOT satisfy the
// 'ssm' control thanks to the anchored regex.
resource "aws_vpc" "fail_only_ssm_family_relatives" {
  expect_failure = true
  attrs = {
    id         = "vpc-66666666"
    cidr_block = "10.7.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ssm_contacts_only" {
  skip = true
  attrs = {
    vpc_id            = "vpc-66666666"
    service_name      = "com.amazonaws.us-east-1.ssm-contacts"
    vpc_endpoint_type = "Interface"
  }
}

resource "aws_vpc_endpoint" "fail_ssm_incidents_only" {
  skip = true
  attrs = {
    vpc_id            = "vpc-66666666"
    service_name      = "com.amazonaws.us-east-1.ssm-incidents"
    vpc_endpoint_type = "Interface"
  }
}

resource "aws_vpc_endpoint" "fail_ssmmessages_only" {
  skip = true
  attrs = {
    vpc_id            = "vpc-66666666"
    service_name      = "com.amazonaws.us-east-1.ssmmessages"
    vpc_endpoint_type = "Interface"
  }
}

// Test 8: PASS - FIPS variant (ssm-fips) is accepted
resource "aws_vpc" "pass_ssm_fips" {
  attrs = {
    id         = "vpc-fips0001"
    cidr_block = "10.8.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ssm_fips_endpoint" {
  skip = true
  attrs = {
    vpc_id            = "vpc-fips0001"
    service_name      = "com.amazonaws.us-east-1.ssm-fips"
    vpc_endpoint_type = "Interface"
  }
}
