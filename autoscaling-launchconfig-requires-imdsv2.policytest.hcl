# Copyright IBM Corp. 2026

policytest {
  targets = [
    "autoscaling-launchconfig-requires-imdsv2.policy.hcl"
  ]
}
# Test 1: PASS - Launch configuration with IMDSv2 enabled (http_tokens = "required")
resource "aws_launch_configuration" "pass_lc_with_imdsv2_required" {
  attrs = {
    name = "compliant-lc"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_endpoint = "enabled"
        http_tokens = "required"
        http_put_response_hop_limit = 1
      }
    ]
  }
}

# Test 2: FAIL - Launch configuration without metadata_options block
resource "aws_launch_configuration" "fail_lc_without_metadata_options" {
  expect_failure = true
  attrs = {
    name = "no-metadata-lc"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = []
  }
}

# Test 3: FAIL - Launch configuration with http_tokens set to "optional"
resource "aws_launch_configuration" "fail_lc_with_http_tokens_optional" {
  expect_failure = true
  attrs = {
    name = "optional-tokens-lc"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_endpoint = "enabled"
        http_tokens = "optional"
        http_put_response_hop_limit = 1
      }
    ]
  }
}



# Test 6: FILTERED - Auto Scaling Group using launch_template (should be filtered out)
resource "aws_autoscaling_group" "filtered_asg_with_launch_template" {
  attrs = {
    name = "template-asg"
    launch_template = [
      {
        id = "lt-12345"
        version = "$Latest"
      }
    ]
    max_size = 5
    min_size = 1
    desired_capacity = 2
    vpc_zone_identifier = ["subnet-12345"]
  }
}

# Test 7: PASS - Launch configuration with complete metadata_options
resource "aws_launch_configuration" "pass_lc_with_complete_metadata_options" {
  attrs = {
    name = "complete-lc"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = [
      {
        http_endpoint = "enabled"
        http_tokens = "required"
        http_put_response_hop_limit = 2
      }
    ]
    security_groups = ["sg-12345"]
    iam_instance_profile = "my-profile"
  }
}

# Test 8: FAIL - Launch configuration with empty metadata_options list
resource "aws_launch_configuration" "fail_lc_with_empty_metadata_options" {
  expect_failure = true
  attrs = {
    name = "empty-metadata-lc"
    image_id = "ami-12345678"
    instance_type = "t3.micro"
    metadata_options = []
  }
}