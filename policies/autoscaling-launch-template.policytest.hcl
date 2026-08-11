# Copyright IBM Corp. 2026

policytest {
  targets = [
    "autoscaling-launch-template.policy.hcl"
  ]
}
# Test 1: Pass - Auto Scaling Group with launch_template configured
resource "aws_autoscaling_group" "with_template" {
  attrs = {
    name = "asg-with-template"
    max_size = 5
    min_size = 1
    launch_template = {
      id = "lt-0123456789abcdef0"
      version = "$Latest"
    }
  }
}

# Test 2: Pass - Auto Scaling Group with mixed_instances_policy.launch_template
resource "aws_autoscaling_group" "with_mixed_policy" {
  attrs = {
    name = "asg-with-mixed-policy"
    max_size = 10
    min_size = 2
    mixed_instances_policy = [
      {
        launch_template = {
          launch_template_specification = {
            launch_template_id = "lt-0123456789abcdef1"
            version = "$Default"
          }
        }
        instances_distribution = {
          on_demand_base_capacity = 1
          on_demand_percentage_above_base_capacity = 50
        }
      }
    ]
  }
}

# Test 3: Pass - Auto Scaling Group with both launch_template and launch_configuration
resource "aws_autoscaling_group" "with_both" {
  attrs = {
    name = "asg-with-both"
    max_size = 3
    min_size = 1
    launch_template = {
      name = "my-launch-template"
      version = "1"
    }
    launch_configuration = "my-launch-config"
  }
}

# Test 4: Fail - Auto Scaling Group with only launch_configuration
resource "aws_autoscaling_group" "only_config" {
  expect_failure = true
  attrs = {
    name = "asg-only-config"
    max_size = 5
    min_size = 1
    launch_configuration = "my-old-launch-config"
  }
}

# Test 5: Fail - Auto Scaling Group with neither launch_template nor launch_configuration
resource "aws_autoscaling_group" "no_launch_method" {
  expect_failure = true
  attrs = {
    name = "asg-no-launch-method"
    max_size = 3
    min_size = 1
  }
}
