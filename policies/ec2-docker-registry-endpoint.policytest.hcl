# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-docker-registry-endpoint.policy.hcl"
  ]
}

# Test 1: PASS - VPC with Interface VPC endpoint for ECR Docker Registry (us-east-1)
resource "aws_vpc" "pass_vpc_with_ecr_dkr_endpoint" {
  attrs = {
    id         = "vpc-12345678"
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "compliant-vpc-us-east-1"
    }
  }
}

resource "aws_vpc_endpoint" "pass_ecr_dkr_us_east_1" {
  skip = true
  attrs = {
    vpc_id            = "vpc-12345678"
    service_name      = "com.amazonaws.us-east-1.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-11111111", "subnet-22222222"]
  }
}

# Test 2: PASS - VPC with Interface ECR Docker Registry endpoint in eu-west-1
resource "aws_vpc" "pass_vpc_eu_west_1" {
  attrs = {
    id         = "vpc-55667788"
    cidr_block = "10.5.0.0/16"
    tags = {
      Name = "compliant-vpc-eu-west-1"
    }
  }
}

resource "aws_vpc_endpoint" "pass_ecr_dkr_eu_west_1" {
  skip = true
  attrs = {
    vpc_id            = "vpc-55667788"
    service_name      = "com.amazonaws.eu-west-1.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-33333333"]
  }
}

# Test 3: PASS - VPC in a brand-new region (regex-based match keeps working)
resource "aws_vpc" "pass_vpc_new_region" {
  attrs = {
    id         = "vpc-newregion"
    cidr_block = "10.6.0.0/16"
    tags = {
      Name = "compliant-vpc-new-region"
    }
  }
}

resource "aws_vpc_endpoint" "pass_ecr_dkr_new_region" {
  skip = true
  attrs = {
    vpc_id            = "vpc-newregion"
    service_name      = "com.amazonaws.ap-future-1.ecr.dkr"
    vpc_endpoint_type = "Interface"
  }
}

# Test 4: FAIL - VPC without any VPC endpoints
resource "aws_vpc" "fail_vpc_without_endpoints" {
  expect_failure = true
  attrs = {
    id         = "vpc-87654321"
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "non-compliant-no-endpoints"
    }
  }
}

# Test 5: FAIL - VPC with Gateway-type endpoint for ECR DKR (must be Interface)
resource "aws_vpc" "fail_vpc_with_gateway_endpoint" {
  expect_failure = true
  attrs = {
    id         = "vpc-11223344"
    cidr_block = "10.2.0.0/16"
    tags = {
      Name = "non-compliant-gateway"
    }
  }
}

resource "aws_vpc_endpoint" "fail_gateway_endpoint" {
  skip = true
  attrs = {
    vpc_id            = "vpc-11223344"
    service_name      = "com.amazonaws.us-east-1.ecr.dkr"
    vpc_endpoint_type = "Gateway"
  }
}

# Test 6: FAIL - VPC with Interface endpoint for a different service (S3, not ecr.dkr)
resource "aws_vpc" "fail_vpc_wrong_service" {
  expect_failure = true
  attrs = {
    id         = "vpc-99887766"
    cidr_block = "10.3.0.0/16"
    tags = {
      Name = "non-compliant-wrong-service"
    }
  }
}

resource "aws_vpc_endpoint" "fail_s3_interface_endpoint" {
  skip = true
  attrs = {
    vpc_id            = "vpc-99887766"
    service_name      = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Interface"
  }
}

# Test 7: FAIL - VPC with Interface endpoint for ECR API (ecr.api), not ecr.dkr
resource "aws_vpc" "fail_vpc_ecr_api_only" {
  expect_failure = true
  attrs = {
    id         = "vpc-apionly"
    cidr_block = "10.4.0.0/16"
    tags = {
      Name = "non-compliant-api-only"
    }
  }
}

resource "aws_vpc_endpoint" "fail_ecr_api_only" {
  skip = true
  attrs = {
    vpc_id            = "vpc-apionly"
    service_name      = "com.amazonaws.us-east-1.ecr.api"
    vpc_endpoint_type = "Interface"
  }
}

# Test 8: PASS - VPC with multiple endpoints including the required ECR DKR Interface
resource "aws_vpc" "pass_vpc_multi_endpoints" {
  attrs = {
    id         = "vpc-multiep"
    cidr_block = "10.7.0.0/16"
    tags = {
      Name = "compliant-multi-endpoints"
    }
  }
}

resource "aws_vpc_endpoint" "pass_multi_s3" {
  skip = true
  attrs = {
    vpc_id            = "vpc-multiep"
    service_name      = "com.amazonaws.us-west-2.s3"
    vpc_endpoint_type = "Gateway"
  }
}

resource "aws_vpc_endpoint" "pass_multi_ecr_api" {
  skip = true
  attrs = {
    vpc_id            = "vpc-multiep"
    service_name      = "com.amazonaws.us-west-2.ecr.api"
    vpc_endpoint_type = "Interface"
  }
}

resource "aws_vpc_endpoint" "pass_multi_ecr_dkr" {
  skip = true
  attrs = {
    vpc_id            = "vpc-multiep"
    service_name      = "com.amazonaws.us-west-2.ecr.dkr"
    vpc_endpoint_type = "Interface"
  }
}

# Test 9: PASS - FIPS variant (ecr.dkr-fips) is accepted
resource "aws_vpc" "pass_vpc_ecr_dkr_fips" {
  attrs = {
    id         = "vpc-fips0001"
    cidr_block = "10.8.0.0/16"
    tags = {
      Name = "compliant-fips"
    }
  }
}

resource "aws_vpc_endpoint" "pass_ecr_dkr_fips" {
  skip = true
  attrs = {
    vpc_id            = "vpc-fips0001"
    service_name      = "com.amazonaws.us-east-1.ecr.dkr-fips"
    vpc_endpoint_type = "Interface"
    subnet_ids        = ["subnet-fips0001"]
  }
}
