# Copyright IBM Corp. 2026

policytest {
  targets = ["ecs-capacity-provider-termination-check.policy.hcl"]
}

# Test 1: Pass - Both managed_termination_protection and managed_scaling enabled
resource "aws_ecs_capacity_provider" "pass_both_enabled" {
  attrs = {
    name = "compliant-capacity-provider"
    auto_scaling_group_provider = [
      {
        auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:12345678-1234-1234-1234-123456789012:autoScalingGroupName/my-asg"
        managed_termination_protection = "ENABLED"
        managed_scaling = [
          {
            status = "ENABLED"
            target_capacity = 80
            maximum_scaling_step_size = 10
            minimum_scaling_step_size = 1
          }
        ]
      }
    ]
  }
}

# Test 2: Fail - managed_termination_protection is DISABLED
resource "aws_ecs_capacity_provider" "fail_termination_protection_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-termination-provider"
    auto_scaling_group_provider = [
      {
        auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:12345678-1234-1234-1234-123456789012:autoScalingGroupName/my-asg"
        managed_termination_protection = "DISABLED"
        managed_scaling = [
          {
            status = "ENABLED"
            target_capacity = 80
          }
        ]
      }
    ]
  }
}

# Test 3: Fail - managed_scaling.status is DISABLED
resource "aws_ecs_capacity_provider" "fail_managed_scaling_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-scaling-provider"
    auto_scaling_group_provider = [
      {
        auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:12345678-1234-1234-1234-123456789012:autoScalingGroupName/my-asg"
        managed_termination_protection = "ENABLED"
        managed_scaling = [
          {
            status = "DISABLED"
          }
        ]
      }
    ]
  }
}

# Test 4: Fail - Both managed_termination_protection and managed_scaling are DISABLED
resource "aws_ecs_capacity_provider" "fail_both_disabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-both-provider"
    auto_scaling_group_provider = [
      {
        auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:12345678-1234-1234-1234-123456789012:autoScalingGroupName/my-asg"
        managed_termination_protection = "DISABLED"
        managed_scaling = [
          {
            status = "DISABLED"
          }
        ]
      }
    ]
  }
}

# Test 5: Fail - managed_termination_protection not explicitly set (defaults to DISABLED)
resource "aws_ecs_capacity_provider" "fail_termination_protection_not_set" {
  expect_failure = true
  attrs = {
    name = "non-compliant-default-provider"
    auto_scaling_group_provider = [
      {
        auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:12345678-1234-1234-1234-123456789012:autoScalingGroupName/my-asg"
        managed_scaling = [
          {
            status = "ENABLED"
            target_capacity = 80
          }
        ]
      }
    ]
  }
}

# Test 6: Filtered out - Capacity provider using managed_instances_provider (should not be evaluated)
resource "aws_ecs_capacity_provider" "filtered_managed_instances_provider" {
  attrs = {
    name = "managed-instances-provider"
    cluster = "my-cluster"
    managed_instances_provider = [
      {
        instance_type = "t3.medium"
      }
    ]
  }
}