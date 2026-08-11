# Copyright IBM Corp. 2026

policytest {
  targets = [
    "autoscaling-group-elb-healthcheck-required.policy.hcl"
  ]
}

# PASS: Auto Scaling group with Classic Load Balancer and ELB health checks
resource "aws_autoscaling_group" "pass_classic_elb_with_elb_healthcheck" {
  attrs = {
    name                      = "asg-with-classic-elb"
    max_size                  = 5
    min_size                  = 1
    desired_capacity          = 2
    health_check_type         = "ELB"
    health_check_grace_period = 300
    load_balancers            = ["my-classic-elb"]
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# PASS: Auto Scaling group with ALB/NLB target groups and ELB health checks
resource "aws_autoscaling_group" "pass_target_groups_with_elb_healthcheck" {
  attrs = {
    name                      = "asg-with-target-groups"
    max_size                  = 10
    min_size                  = 2
    desired_capacity          = 5
    health_check_type         = "ELB"
    health_check_grace_period = 300
    target_group_arns         = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/50dc6c495c0c9188"]
    vpc_zone_identifier       = ["subnet-12345", "subnet-67890"]
  }
}

# PASS: Auto Scaling group with both Classic ELB and target groups, using ELB health checks
resource "aws_autoscaling_group" "pass_both_lb_types_with_elb_healthcheck" {
  attrs = {
    name                      = "asg-with-both-lb-types"
    max_size                  = 8
    min_size                  = 2
    desired_capacity          = 4
    health_check_type         = "ELB"
    health_check_grace_period = 300
    load_balancers            = ["my-classic-elb"]
    target_group_arns         = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/50dc6c495c0c9188"]
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# PASS (Not Applicable): Auto Scaling group without any load balancer - should be filtered out
resource "aws_autoscaling_group" "pass_no_load_balancer" {
  attrs = {
    name                      = "asg-without-lb"
    max_size                  = 3
    min_size                  = 1
    desired_capacity          = 2
    health_check_type         = "EC2"
    health_check_grace_period = 300
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# PASS (Not Applicable): Auto Scaling group with empty load_balancers list
resource "aws_autoscaling_group" "pass_empty_load_balancers" {
  attrs = {
    name                      = "asg-empty-lb-list"
    max_size                  = 3
    min_size                  = 1
    desired_capacity          = 2
    health_check_type         = "EC2"
    health_check_grace_period = 300
    load_balancers            = []
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# FAIL: Auto Scaling group with Classic Load Balancer but EC2 health checks
resource "aws_autoscaling_group" "fail_classic_elb_with_ec2_healthcheck" {
  expect_failure = true
  attrs = {
    name                      = "asg-classic-elb-ec2"
    max_size                  = 5
    min_size                  = 1
    desired_capacity          = 2
    health_check_type         = "EC2"
    health_check_grace_period = 300
    load_balancers            = ["my-classic-elb"]
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# FAIL: Auto Scaling group with target groups but EC2 health checks
resource "aws_autoscaling_group" "fail_target_groups_with_ec2_healthcheck" {
  expect_failure = true
  attrs = {
    name                      = "asg-target-groups-ec2"
    max_size                  = 10
    min_size                  = 2
    desired_capacity          = 5
    health_check_type         = "EC2"
    health_check_grace_period = 300
    target_group_arns         = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/50dc6c495c0c9188"]
    vpc_zone_identifier       = ["subnet-12345", "subnet-67890"]
  }
}

# FAIL: Auto Scaling group with Classic Load Balancer but no health_check_type (defaults to EC2)
resource "aws_autoscaling_group" "fail_classic_elb_default_healthcheck" {
  expect_failure = true
  attrs = {
    name                      = "asg-classic-elb-default"
    max_size                  = 5
    min_size                  = 1
    desired_capacity          = 2
    health_check_grace_period = 300
    load_balancers            = ["my-classic-elb"]
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# FAIL: Auto Scaling group with both load balancer types but no health_check_type specified
resource "aws_autoscaling_group" "fail_both_lb_types_default_healthcheck" {
  expect_failure = true
  attrs = {
    name                      = "asg-both-default"
    max_size                  = 8
    min_size                  = 2
    desired_capacity          = 4
    health_check_grace_period = 300
    load_balancers            = ["my-classic-elb"]
    target_group_arns         = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/50dc6c495c0c9188"]
    vpc_zone_identifier       = ["subnet-12345"]
  }
}

# FAIL: Auto Scaling group with multiple target groups but EC2 health checks
resource "aws_autoscaling_group" "fail_multiple_target_groups_ec2" {
  expect_failure = true
  attrs = {
    name                      = "asg-multiple-tg-ec2"
    max_size                  = 10
    min_size                  = 3
    desired_capacity          = 6
    health_check_type         = "EC2"
    health_check_grace_period = 300
    target_group_arns         = [
      "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets-1/50dc6c495c0c9188",
      "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets-2/60dc6c495c0c9199"
    ]
    vpc_zone_identifier       = ["subnet-12345", "subnet-67890"]
  }
}