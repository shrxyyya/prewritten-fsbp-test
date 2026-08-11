# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-spot-fleet-request-ct-encryption-at-rest.policy.hcl"
  ]
}

# Pass case: Encrypted root and EBS block devices
resource "aws_spot_fleet_request" "pass_encrypted_volumes" {
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = true
            volume_type = "gp3"
            volume_size = 20
          }
        ]
        ebs_block_device = [
          {
            device_name = "/dev/sdf"
            encrypted = true
            volume_type = "gp3"
            volume_size = 100
          }
        ]
      }
    ]
  }
}

# Fail case: Unencrypted root block device
resource "aws_spot_fleet_request" "fail_unencrypted_root_device" {
  expect_failure = true
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = false
            volume_type = "gp3"
            volume_size = 20
          }
        ]
      }
    ]
  }
}

# Fail case: Unencrypted EBS block device
resource "aws_spot_fleet_request" "fail_unencrypted_ebs_device" {
  expect_failure = true
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = true
            volume_type = "gp3"
            volume_size = 20
          }
        ]
        ebs_block_device = [
          {
            device_name = "/dev/sdf"
            encrypted = false
            volume_type = "gp3"
            volume_size = 100
          }
        ]
      }
    ]
  }
}

# Fail case: Both root and EBS devices unencrypted
resource "aws_spot_fleet_request" "fail_both_unencrypted" {
  expect_failure = true
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = false
            volume_type = "gp3"
            volume_size = 20
          }
        ]
        ebs_block_device = [
          {
            device_name = "/dev/sdf"
            encrypted = false
            volume_type = "gp3"
            volume_size = 100
          }
        ]
      }
    ]
  }
}

# Fail case: Multiple launch specs with some unencrypted
resource "aws_spot_fleet_request" "fail_multiple_specs_mixed" {
  expect_failure = true
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = true
            volume_type = "gp3"
            volume_size = 20
          }
        ]
      },
      {
        ami = "ami-87654321"
        instance_type = "t3.small"
        root_block_device = [
          {
            encrypted = false
            volume_type = "gp3"
            volume_size = 20
          }
        ]
      }
    ]
  }
}

# Fail case: Encrypted explicitly set to false
resource "aws_spot_fleet_request" "fail_explicit_false" {
  expect_failure = true
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        ebs_block_device = [
          {
            device_name = "/dev/sdf"
            encrypted = false
            volume_type = "gp3"
            volume_size = 100
          }
        ]
      }
    ]
  }
}

# Fail case: launch_template_config used but launch_specification missing
# (EC2.173 requires launch_specification with EBS encryption settings).
resource "aws_spot_fleet_request" "fail_launch_template_no_spec" {
  expect_failure = true
  attrs = {
    launch_template_config = [
      {
        launch_template_specification = {
          id = "lt-12345678"
          version = "$Latest"
        }
      }
    ]
  }
}

# Fail case: No launch_specification defined
resource "aws_spot_fleet_request" "fail_no_launch_spec" {
  expect_failure = true
  attrs = {
    iam_fleet_role = "arn:aws:iam::123456789012:role/fleet-role"
    target_capacity = 2
  }
}

# Pass case: Multiple launch specs all encrypted
resource "aws_spot_fleet_request" "pass_multiple_specs_all_encrypted" {
  attrs = {
    launch_specification = [
      {
        ami = "ami-12345678"
        instance_type = "t3.micro"
        root_block_device = [
          {
            encrypted = true
            volume_type = "gp3"
            volume_size = 20
          }
        ]
        ebs_block_device = [
          {
            device_name = "/dev/sdf"
            encrypted = true
            volume_type = "gp3"
            volume_size = 100
          }
        ]
      },
      {
        ami = "ami-87654321"
        instance_type = "t3.small"
        root_block_device = [
          {
            encrypted = true
            volume_type = "gp3"
            volume_size = 30
          }
        ]
      }
    ]
  }
}