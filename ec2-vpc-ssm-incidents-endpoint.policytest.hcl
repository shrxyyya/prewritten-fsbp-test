# Copyright IBM Corp. 2026

policytest {
  targets = ["ec2-vpc-ssm-incidents-endpoint.policy.hcl"]
}

# ---------------------------------------------------------------------------
# PASS cases
# ---------------------------------------------------------------------------

# Test 1: PASS - VPC has a matching ssm-incidents Interface endpoint (us-east-1)
resource "aws_vpc" "pass_vpc_us_east_1" {
  attrs = {
    id         = "vpc-pass00000001"
    cidr_block = "10.0.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ep_us_east_1" {
  attrs = {
    vpc_id            = "vpc-pass00000001"
    service_name      = "com.amazonaws.us-east-1.ssm-incidents"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-1111"]
  }
}

# Test 2: PASS - VPC has a matching ssm-incidents Interface endpoint (eu-central-1)
resource "aws_vpc" "pass_vpc_eu_central_1" {
  attrs = {
    id         = "vpc-pass00000002"
    cidr_block = "10.1.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ep_eu_central_1" {
  attrs = {
    vpc_id            = "vpc-pass00000002"
    service_name      = "com.amazonaws.eu-central-1.ssm-incidents"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-2222"]
  }
}

# Test 3: PASS - FIPS variant (ssm-incidents-fips) is accepted
resource "aws_vpc" "pass_vpc_fips" {
  attrs = {
    id         = "vpc-pass0000fips"
    cidr_block = "10.2.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ep_fips" {
  attrs = {
    vpc_id            = "vpc-pass0000fips"
    service_name      = "com.amazonaws.us-east-1.ssm-incidents-fips"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-3333"]
  }
}

# Test 4: PASS - GovCloud partition endpoint is accepted
resource "aws_vpc" "pass_vpc_govcloud" {
  attrs = {
    id         = "vpc-pass0000gov0"
    cidr_block = "10.3.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ep_govcloud" {
  attrs = {
    vpc_id            = "vpc-pass0000gov0"
    service_name      = "com.amazonaws-us-gov.us-gov-west-1.ssm-incidents"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-4444"]
  }
}

# ---------------------------------------------------------------------------
# FAIL cases
# ---------------------------------------------------------------------------

# Test 5: FAIL - VPC has no endpoints at all
resource "aws_vpc" "fail_vpc_no_endpoints" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail00000001"
    cidr_block = "10.10.0.0/16"
  }
}

# Test 6: FAIL - VPC only has an endpoint for a different service (ec2)
resource "aws_vpc" "fail_vpc_wrong_service" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail00000002"
    cidr_block = "10.11.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ep_wrong_service" {
  attrs = {
    vpc_id            = "vpc-fail00000002"
    service_name      = "com.amazonaws.us-east-1.ec2"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-5555"]
  }
}

# Test 7: FAIL - ssm-incidents endpoint exists but is Gateway type, not Interface
resource "aws_vpc" "fail_vpc_gateway_type" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail00000003"
    cidr_block = "10.12.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ep_gateway_type" {
  attrs = {
    vpc_id            = "vpc-fail00000003"
    service_name      = "com.amazonaws.us-east-1.ssm-incidents"
    vpc_endpoint_type = "Gateway"
  }
}

# Test 8: FAIL - related-but-not-equal service name (ssm, not ssm-incidents)
resource "aws_vpc" "fail_vpc_ssm_only" {
  expect_failure = true
  attrs = {
    id         = "vpc-fail00000004"
    cidr_block = "10.13.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ep_ssm_only" {
  attrs = {
    vpc_id            = "vpc-fail00000004"
    service_name      = "com.amazonaws.us-east-1.ssm"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-6666"]
  }
}
