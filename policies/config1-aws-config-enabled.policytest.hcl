# Copyright IBM Corp. 2026

policytest {
  targets = ["config1-aws-config-enabled.policy.hcl"]
}

# Test 1: PASS - Complete configuration recorder with all requirements
resource "aws_config_configuration_recorder" "pass_complete_configuration" {
  attrs = {
    name = "default"
    role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
    recording_group = {
      all_supported = true
      include_global_resource_types = true
      resource_types = []
    }
  }
}

resource "aws_iam_service_linked_role" "pass_config_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
    name = "AWSServiceRoleForConfig"
  }
}

# Test 2: FAIL - Configuration recorder with all_supported=false
resource "aws_config_configuration_recorder" "fail_all_supported_false" {
  expect_failure = true
  attrs = {
    name = "default"
    role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
    recording_group = {
      all_supported = false
      include_global_resource_types = true
      resource_types = ["AWS::EC2::Instance"]
    }
  }
}

resource "aws_iam_service_linked_role" "fail_all_supported_false_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
  }
}

# Test 3: FAIL - Configuration recorder with include_global_resource_types=false
resource "aws_config_configuration_recorder" "fail_include_global_false" {
  expect_failure = true
  attrs = {
    name = "default"
    role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
    recording_group = {
      all_supported = true
      include_global_resource_types = false
      resource_types = []
    }
  }
}

resource "aws_iam_service_linked_role" "fail_include_global_false_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
  }
}

# Test 4: FAIL - Configuration recorder without recording_group
resource "aws_config_configuration_recorder" "fail_no_recording_group" {
  expect_failure = true
  attrs = {
    name = "default"
    role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
    recording_group = {}
  }
}

resource "aws_iam_service_linked_role" "fail_no_recording_group_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
  }
}



# Test 6: PASS - Configuration recorder status enabled
resource "aws_config_configuration_recorder_status" "pass_status_enabled" {
  attrs = {
    name = "default"
    is_enabled = true
  }
}

# Test 7: FAIL - Configuration recorder status disabled
resource "aws_config_configuration_recorder_status" "fail_status_disabled" {
  expect_failure = true
  attrs = {
    name = "default"
    is_enabled = false
  }
}

# Test 8: PASS - Delivery channel with S3 bucket configured
resource "aws_config_delivery_channel" "pass_with_s3_bucket" {
  attrs = {
    name = "default"
    s3_bucket_name = "config-bucket-123456789012"
    s3_key_prefix = "config"
  }
}

# Test 9: FAIL - Delivery channel without S3 bucket
resource "aws_config_delivery_channel" "fail_no_s3_bucket" {
  expect_failure = true
  attrs = {
    name = "default"
    s3_bucket_name = ""
  }
}

# Test 10: PASS - Service-linked role for AWS Config
resource "aws_iam_service_linked_role" "pass_service_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
    name = "AWSServiceRoleForConfig"
    description = "Service-linked role for AWS Config"
  }
}

# Test 11: PASS - Complete AWS Config setup with all components
resource "aws_config_configuration_recorder" "pass_complete_setup_recorder" {
  attrs = {
    name = "complete-setup"
    role_arn = "arn:aws:iam::123456789012:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
    recording_group = {
      all_supported = true
      include_global_resource_types = true
      resource_types = []
    }
  }
}

resource "aws_config_configuration_recorder_status" "pass_complete_setup_status" {
  attrs = {
    name = "complete-setup"
    is_enabled = true
  }
}

resource "aws_config_delivery_channel" "pass_complete_setup_channel" {
  attrs = {
    name = "complete-setup-channel"
    s3_bucket_name = "config-bucket-123456789012"
  }
}

resource "aws_iam_service_linked_role" "pass_complete_setup_role" {
  attrs = {
    aws_service_name = "config.amazonaws.com"
    name = "AWSServiceRoleForConfig"
  }
}

