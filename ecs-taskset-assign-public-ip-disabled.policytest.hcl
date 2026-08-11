# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-taskset-assign-public-ip-disabled.policy.hcl"
    ]
}

# Test 1: PASS - assign_public_ip explicitly set to false
resource "aws_ecs_task_set" "compliant_explicit" {
  attrs = {
    service = "my-service"
    cluster = "my-cluster"
    task_definition = "my-task:1"
    network_configuration = [
      {
        subnets = ["subnet-12345"]
        security_groups = ["sg-12345"]
        assign_public_ip = false
      }
    ]
  }
}

# Test 2: PASS - assign_public_ip not specified (defaults to false)
resource "aws_ecs_task_set" "compliant_default" {
  attrs = {
    service = "my-service"
    cluster = "my-cluster"
    task_definition = "my-task:1"
    network_configuration = [
      {
        subnets = ["subnet-12345"]
        security_groups = ["sg-12345"]
      }
    ]
  }
}

# Test 3: FAIL - assign_public_ip set to true
resource "aws_ecs_task_set" "non_compliant" {
  expect_failure = true
  attrs = {
    service = "my-service"
    cluster = "my-cluster"
    task_definition = "my-task:1"
    network_configuration = [
      {
        subnets = ["subnet-12345"]
        security_groups = ["sg-12345"]
        assign_public_ip = true
      }
    ]
  }
}

# Test 4: PASS - No network_configuration (no failures)
resource "aws_ecs_task_set" "no_network_config" {
  attrs = {
    service = "my-service"
    cluster = "my-cluster"
    task_definition = "my-task:1"
  }
}