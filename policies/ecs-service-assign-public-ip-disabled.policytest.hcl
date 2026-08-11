# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-service-assign-public-ip-disabled.policy.hcl"
    ]
}

# Test 1: PASS - assign_public_ip explicitly set to false
resource "aws_ecs_service" "pass_explicit_false" {
  attrs = {
    name = "compliant-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    network_configuration = [
      {
        assign_public_ip = false
        security_groups = ["sg-12345678"]
        subnets = ["subnet-12345678", "subnet-87654321"]
      }
    ]
    desired_count = 2
  }
}

# Test 2: PASS - assign_public_ip not specified (defaults to false)
resource "aws_ecs_service" "pass_default_false" {
  attrs = {
    name = "default-compliant-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    network_configuration = [
      {
        security_groups = ["sg-12345678"]
        subnets = ["subnet-12345678", "subnet-87654321"]
      }
    ]
    desired_count = 2
  }
}

# Test 3: PASS - no network_configuration (not using awsvpc mode)
resource "aws_ecs_service" "pass_no_network_config" {
  attrs = {
    name = "ec2-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "EC2"
    desired_count = 2
  }
}

# Test 4: FAIL - assign_public_ip explicitly set to true
resource "aws_ecs_service" "fail_public_ip_enabled" {
  expect_failure = true
  attrs = {
    name = "non-compliant-service"
    cluster = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    task_definition = "my-task:1"
    launch_type = "FARGATE"
    network_configuration = [
      {
        assign_public_ip = true
        security_groups = ["sg-12345678"]
        subnets = ["subnet-12345678", "subnet-87654321"]
      }
    ]
    desired_count = 2
  }
}
