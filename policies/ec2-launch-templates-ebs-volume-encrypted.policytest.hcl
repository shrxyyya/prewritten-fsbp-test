# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-launch-templates-ebs-volume-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - Single EBS volume with encryption enabled
resource "aws_launch_template" "pass_single_volume_encrypted" {
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = true
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - Single EBS volume with encryption explicitly set to false
resource "aws_launch_template" "fail_single_volume_not_encrypted" {
  expect_failure = true
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = false
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Single EBS volume without encryption parameter
resource "aws_launch_template" "fail_single_volume_encryption_not_specified" {
  expect_failure = true
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - Multiple EBS volumes all encrypted
resource "aws_launch_template" "pass_multiple_volumes_all_encrypted" {
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = true
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      },
      {
        device_name = "/dev/sdb"
        ebs = [
          {
            encrypted = true
            volume_size = 100
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 5: FAIL - Multiple EBS volumes with mixed encryption (some true, some false)
resource "aws_launch_template" "fail_multiple_volumes_mixed_encryption" {
  expect_failure = true
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = true
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      },
      {
        device_name = "/dev/sdb"
        ebs = [
          {
            encrypted = false
            volume_size = 100
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 6: FAIL - Multiple EBS volumes with some encrypted and some missing encryption parameter
resource "aws_launch_template" "fail_multiple_volumes_some_missing_encryption" {
  expect_failure = true
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = true
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      },
      {
        device_name = "/dev/sdb"
        ebs = [
          {
            volume_size = 100
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}

# Test 7: PASS - No block device mappings defined
resource "aws_launch_template" "pass_no_block_device_mappings" {
  attrs = {
    name = "example-template"
    image_id = "ami-12345678"
  }
}

# Test 8: PASS - Block device mappings without EBS configuration
resource "aws_launch_template" "pass_block_mappings_no_ebs" {
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        virtual_name = "ephemeral0"
      }
    ]
  }
}

# Test 9: PASS - Encrypted EBS volume with KMS key specified
resource "aws_launch_template" "pass_encrypted_with_kms_key" {
  attrs = {
    block_device_mappings = [
      {
        device_name = "/dev/sda1"
        ebs = [
          {
            encrypted = true
            kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
            volume_size = 20
            volume_type = "gp3"
          }
        ]
      }
    ]
  }
}