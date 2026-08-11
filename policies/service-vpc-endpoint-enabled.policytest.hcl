# Copyright IBM Corp. 2026

policytest {
  targets = ["service-vpc-endpoint-enabled.policy.hcl"]
}

# Test 1: PASS - VPC with EC2 interface endpoint and full configuration
resource "aws_vpc_endpoint" "pass_endpoint_fully_configured" {
  attrs = {
    vpc_id = "vpc-complete123"
    service_name = "com.amazonaws.eu-west-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-111"]
    security_group_ids = ["sg-111"]
    private_dns_enabled = true
  }
}

resource "aws_vpc" "vpc_with_complete_endpoint" {
  attrs = {
    id         = "vpc-complete123"
    cidr_block = "10.0.0.0/16"
  }
}

# Test 2: PASS - VPC with EC2 endpoint in us-east-1
resource "aws_vpc_endpoint" "pass_ec2_endpoint_us_east_1" {
  attrs = {
    vpc_id = "vpc-12345678"
    service_name = "com.amazonaws.us-east-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-abc123"]
    security_group_ids = ["sg-123456"]
  }
}

resource "aws_vpc" "vpc_with_ec2_endpoint_us_east_1" {
  attrs = {
    id         = "vpc-12345678"
    cidr_block = "10.1.0.0/16"
  }
}

# Test 3: PASS - VPC with EC2 endpoint in us-west-2
resource "aws_vpc_endpoint" "pass_ec2_endpoint_us_west_2" {
  attrs = {
    vpc_id = "vpc-multi123"
    service_name = "com.amazonaws.us-west-2.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-def"]
    security_group_ids = ["sg-def"]
  }
}

resource "aws_vpc" "vpc_with_ec2_endpoint_us_west_2" {
  attrs = {
    id         = "vpc-multi123"
    cidr_block = "10.2.0.0/16"
  }
}

# Test 4: PASS - VPC with EC2 endpoint in eu-central-1
resource "aws_vpc_endpoint" "pass_ec2_endpoint_eu_central" {
  attrs = {
    vpc_id = "vpc-eu123"
    service_name = "com.amazonaws.eu-central-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-eu1"]
    security_group_ids = ["sg-eu1"]
  }
}

resource "aws_vpc" "vpc_with_ec2_endpoint_eu_central" {
  attrs = {
    id         = "vpc-eu123"
    cidr_block = "10.3.0.0/16"
  }
}

# Test 5: FAIL - VPC with only an S3 gateway endpoint
resource "aws_vpc_endpoint" "pass_s3_gateway" {
  attrs = {
    vpc_id = "vpc-gateway123"
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
    subnet_ids = []
    security_group_ids = []
  }
}

resource "aws_vpc" "vpc_with_only_s3_gateway" {
  expect_failure = true
  attrs = {
    id         = "vpc-gateway123"
    cidr_block = "10.4.0.0/16"
  }
}

# Test 6: FAIL - VPC with only an S3 interface endpoint
resource "aws_vpc_endpoint" "pass_s3_interface" {
  attrs = {
    vpc_id = "vpc-s3only123"
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-123"]
    security_group_ids = ["sg-123"]
  }
}

resource "aws_vpc" "vpc_with_only_s3_interface" {
  expect_failure = true
  attrs = {
    id         = "vpc-s3only123"
    cidr_block = "10.5.0.0/16"
  }
}

# Test 7: FAIL - VPC with EC2 endpoint without subnet_ids
resource "aws_vpc_endpoint" "fail_endpoint_no_subnets" {
  attrs = {
    vpc_id = "vpc-nosubnets123"
    service_name = "com.amazonaws.ap-northeast-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = []
    security_group_ids = ["sg-333"]
  }
}

resource "aws_vpc" "vpc_with_endpoint_no_subnets" {
  expect_failure = true
  attrs = {
    id         = "vpc-nosubnets123"
    cidr_block = "10.6.0.0/16"
  }
}

# Test 8: FAIL - VPC with EC2 endpoint without security_group_ids
resource "aws_vpc_endpoint" "fail_endpoint_no_security_groups" {
  attrs = {
    vpc_id = "vpc-nosgs123"
    service_name = "com.amazonaws.ap-southeast-2.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids = ["subnet-444"]
    security_group_ids = []
  }
}

resource "aws_vpc" "vpc_with_endpoint_no_security_groups" {
  expect_failure = true
  attrs = {
    id         = "vpc-nosgs123"
    cidr_block = "10.7.0.0/16"
  }
}

# Test 9: FAIL - VPC without any endpoint
resource "aws_vpc" "vpc_without_endpoint" {
  expect_failure = true
  attrs = {
    id         = "vpc-no-endpoint"
    cidr_block = "10.8.0.0/16"
  }
}