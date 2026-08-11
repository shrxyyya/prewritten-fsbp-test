# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-fargate-latest-platform-version.policy.hcl"
    ]
}

# Test 1: PASS - Fargate service with platform_version = "LATEST"
resource "aws_ecs_service" "pass_latest_version" {
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    platform_version = "LATEST"
    desired_count = 2
  }
}

# Test 2: PASS - Fargate service without platform_version (defaults to LATEST)
resource "aws_ecs_service" "pass_default_latest" {
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    desired_count = 2
  }
}

# Test 3: PASS - Fargate service with explicit latest Linux version (1.4.0)
resource "aws_ecs_service" "pass_explicit_linux_latest" {
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    platform_version = "1.4.0"
    desired_count = 2
  }
}

# Test 4: PASS - Fargate service with explicit latest Windows version (1.0.0)
resource "aws_ecs_service" "pass_explicit_windows_latest" {
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    platform_version = "1.0.0"
    desired_count = 2
  }
}

# Test 5: FAIL - Fargate service with older platform version (1.3.0)
resource "aws_ecs_service" "fail_old_version_1_3_0" {
  expect_failure = true
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    platform_version = "1.3.0"
    desired_count = 2
  }
}

# Test 6: FAIL - Fargate service with older platform version (1.2.0)
resource "aws_ecs_service" "fail_old_version_1_2_0" {
  expect_failure = true
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    platform_version = "1.2.0"
    desired_count = 2
  }
}

# Test 5: SKIP - EC2 launch type (policy filter excludes non-Fargate services)
resource "aws_ecs_service" "skip_ec2_launch_type" {
  attrs = {
    name = "my-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "EC2"
    desired_count = 2
  }
}
