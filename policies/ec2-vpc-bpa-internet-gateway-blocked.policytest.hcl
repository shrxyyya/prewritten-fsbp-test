# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-vpc-bpa-internet-gateway-blocked.policy.hcl"
  ]
}
# Test 1: Pass - InternetGatewayBlockMode set to 'block-bidirectional'
resource "aws_vpc_block_public_access_options" "compliant_bidirectional" {
  attrs = {
    internet_gateway_block_mode = "block-bidirectional"
  }
}

# Test 2: Pass - InternetGatewayBlockMode set to 'block-ingress'
resource "aws_vpc_block_public_access_options" "compliant_ingress" {
  attrs = {
    internet_gateway_block_mode = "block-ingress"
  }
}

# Test 3: Fail - InternetGatewayBlockMode set to 'off'
resource "aws_vpc_block_public_access_options" "non_compliant_off" {
  expect_failure = true
  attrs = {
    internet_gateway_block_mode = "off"
  }
}

# Test 4: Fail - No InternetGatewayBlockMode specified (defaults to 'off')
resource "aws_vpc_block_public_access_options" "non_compliant_missing" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
    # internet_gateway_block_mode not specified, will default to "off" via core::try()
  }
}