# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-launch-template-imdsv2-check.policy.hcl"
    ]
}

# Test 1: PASS - Launch template with http_tokens='required'
resource "aws_launch_template" "pass_http_tokens_required" {
  attrs = {
    name = "test-template-pass"
    metadata_options = [{
        http_tokens = "required"
    }]
  }
}

# Test 2: PASS - Launch template with complete metadata_options and http_tokens='required'
resource "aws_launch_template" "pass_complete_metadata_options" {
  attrs = {
    name = "test-template-complete"
    metadata_options = [{
        http_endpoint = "enabled"
        http_tokens = "required"
        http_put_response_hop_limit = 1
        http_protocol_ipv6 = "disabled"
        instance_metadata_tags = "disabled"
    }]
  }
}

# Test 3: FAIL - Launch template with http_tokens='optional'
resource "aws_launch_template" "fail_http_tokens_optional" {
  expect_failure = true
  attrs = {
    name = "test-template-fail-optional"
    metadata_options = [{
        http_tokens = "optional"
    }]
  }
}

# Test 4: FAIL - Launch template with metadata_options but http_tokens not specified
resource "aws_launch_template" "fail_http_tokens_not_specified" {
  expect_failure = true
  attrs = {
    name = "test-template-fail-not-specified"
    metadata_options = [{
        http_endpoint = "enabled"
    }]
  }
}

# Test 5: FAIL - Launch template without metadata_options block
resource "aws_launch_template" "fail_no_metadata_options" {
  expect_failure = true
  attrs = {
    name = "test-template-fail-no-metadata"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
  }
}
