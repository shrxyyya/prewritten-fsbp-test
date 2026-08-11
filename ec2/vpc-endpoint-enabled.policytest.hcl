# Copyright IBM Corp. 2026

policytest {
  targets = [
    "vpc-endpoint-enabled.policy.hcl"
  ]
}

# Test 1: PASS - VPC with interface VPC endpoint for ECR API (us-east-1)
resource "aws_vpc" "pass_vpc_with_ecr_api_interface_endpoint" {
  attrs = {
    id         = "vpc-12345678"
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "compliant-vpc"
    }
  }
}

resource "aws_vpc_endpoint" "pass_ecr_api_endpoint" {
  attrs = {
    vpc_id            = "vpc-12345678"
    service_name      = "com.amazonaws.us-east-1.ecr.api"
    vpc_endpoint_type = "Interface"
  }
}

# Test 2: FAIL - VPC without any VPC endpoints
resource "aws_vpc" "fail_vpc_without_endpoints" {
  expect_failure = true
  attrs = {
    id         = "vpc-87654321"
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "non-compliant-vpc"
    }
  }
}

# Test 3: PASS - Gateway endpoint should now satisfy if the service matches.
# (Previous policy filtered to Interface-only; the AWS Config rule does not.)
resource "aws_vpc" "pass_vpc_with_gateway_endpoint" {
  attrs = {
    id         = "vpc-11223344"
    cidr_block = "10.2.0.0/16"
    tags = {
      Name = "gateway-vpc"
    }
  }
}

resource "aws_vpc_endpoint" "pass_gateway_endpoint" {
  attrs = {
    vpc_id            = "vpc-11223344"
    service_name      = "com.amazonaws.us-east-1.ecr.api"
    vpc_endpoint_type = "Gateway"
  }
}

# Test 4: FAIL - VPC with interface endpoint for different service
resource "aws_vpc" "fail_vpc_with_different_service" {
  expect_failure = true
  attrs = {
    id         = "vpc-55667788"
    cidr_block = "10.3.0.0/16"
    tags = {
      Name = "different-service-vpc"
    }
  }
}

resource "aws_vpc_endpoint" "fail_s3_endpoint" {
  attrs = {
    vpc_id            = "vpc-55667788"
    service_name      = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
  }
}

# Test 5: PASS - Region-agnostic match: us-west-2 endpoint satisfies default input.
resource "aws_vpc" "pass_vpc_us_west_2" {
  attrs = {
    id         = "vpc-99887766"
    cidr_block = "10.4.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ecr_api_west" {
  attrs = {
    vpc_id            = "vpc-99887766"
    service_name      = "com.amazonaws.us-west-2.ecr.api"
    vpc_endpoint_type = "Interface"
  }
}

# Test 6: PASS - FIPS variant of the endpoint name is accepted.
resource "aws_vpc" "pass_vpc_fips_endpoint" {
  attrs = {
    id         = "vpc-fipsfips"
    cidr_block = "10.5.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_ecr_api_fips" {
  attrs = {
    vpc_id            = "vpc-fipsfips"
    service_name      = "com.amazonaws.us-east-1.ecr.api-fips"
    vpc_endpoint_type = "Interface"
  }
}

# Test 7: FAIL - ECR DKR endpoint should NOT satisfy ECR API requirement
# (anchored regex: ecr.api must not be matched by ecr.dkr).
resource "aws_vpc" "fail_vpc_only_ecr_dkr" {
  expect_failure = true
  attrs = {
    id         = "vpc-dkrdkr00"
    cidr_block = "10.6.0.0/16"
  }
}

resource "aws_vpc_endpoint" "fail_ecr_dkr_only" {
  attrs = {
    vpc_id            = "vpc-dkrdkr00"
    service_name      = "com.amazonaws.us-east-1.ecr.dkr"
    vpc_endpoint_type = "Interface"
  }
}

# Test 8: PASS - Full-form service name (com.amazonaws.<region>.ecr.api) is
# matched literally (with region wildcard + optional -fips suffix).
resource "aws_vpc" "pass_full_form_marker" {
  attrs = {
    id         = "vpc-fullform0"
    cidr_block = "10.8.0.0/16"
  }
}

resource "aws_vpc_endpoint" "pass_full_form_endpoint" {
  attrs = {
    vpc_id            = "vpc-fullform0"
    service_name      = "com.amazonaws.us-east-1.ecr.api"
    vpc_endpoint_type = "Interface"
  }
}