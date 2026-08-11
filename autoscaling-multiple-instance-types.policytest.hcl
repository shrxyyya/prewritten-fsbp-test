# Copyright IBM Corp. 2026

policytest {
  targets = [
    "autoscaling-multiple-instance-types.policy.hcl"
  ]
}
# PASS: Auto Scaling group with 2 instance types and 2 subnets
resource "aws_autoscaling_group" "pass_two_types_two_subnets" {
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-12345"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              },
              {
                instance_type = "t3.small"
              }
            ]
          }
        ]
      }
    ]
    vpc_zone_identifier = ["subnet-abc123", "subnet-def456"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# PASS: Auto Scaling group with 3 instance types and 3 availability zones
resource "aws_autoscaling_group" "pass_three_types_three_azs" {
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-67890"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              },
              {
                instance_type = "t3.small"
              },
              {
                instance_type = "t3.medium"
              }
            ]
          }
        ]
      }
    ]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    min_size = 2
    max_size = 6
    desired_capacity = 3
  }
}

# FAIL: Auto Scaling group using legacy launch_configuration
resource "aws_autoscaling_group" "fail_legacy_launch_configuration" {
  expect_failure = true
  attrs = {
    launch_configuration = "my-launch-config"
    availability_zones = ["us-east-1a", "us-east-1b"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# FAIL: Auto Scaling group without mixed_instances_policy
resource "aws_autoscaling_group" "fail_no_mixed_instances_policy" {
  expect_failure = true
  attrs = {
    launch_template = [
      {
        id = "lt-12345"
        version = "$Latest"
      }
    ]
    vpc_zone_identifier = ["subnet-abc123", "subnet-def456"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# FAIL: Auto Scaling group with only 1 instance type override
resource "aws_autoscaling_group" "fail_single_instance_type" {
  expect_failure = true
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-12345"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              }
            ]
          }
        ]
      }
    ]
    vpc_zone_identifier = ["subnet-abc123", "subnet-def456"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# FAIL: Auto Scaling group with 2 instance types but only 1 subnet
resource "aws_autoscaling_group" "fail_single_subnet" {
  expect_failure = true
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-12345"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              },
              {
                instance_type = "t3.small"
              }
            ]
          }
        ]
      }
    ]
    vpc_zone_identifier = ["subnet-abc123"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# FAIL: Auto Scaling group with 2 instance types but only 1 availability zone
resource "aws_autoscaling_group" "fail_single_availability_zone" {
  expect_failure = true
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-12345"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              },
              {
                instance_type = "t3.small"
              }
            ]
          }
        ]
      }
    ]
    availability_zones = ["us-east-1a"]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}

# FAIL: Auto Scaling group with 2 instance types but no AZ configuration
resource "aws_autoscaling_group" "fail_no_az_configuration" {
  expect_failure = true
  attrs = {
    mixed_instances_policy = [
      {
        launch_template = [
          {
            launch_template_specification = [
              {
                launch_template_id = "lt-12345"
                version = "$Latest"
              }
            ]
            override = [
              {
                instance_type = "t3.micro"
              },
              {
                instance_type = "t3.small"
              }
            ]
          }
        ]
      }
    ]
    min_size = 1
    max_size = 3
    desired_capacity = 2
  }
}