# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecs-task-definition-pid-mode-check.policy.hcl"
  ]
}

# Test 1: PASS - pid_mode not specified (defaults to task-level isolation)
resource "aws_ecs_task_definition" "pass_pid_mode_not_specified" {
  attrs = {
    family = "test-task-default"
    container_definitions = [
        {
            name = "test-container"
            image = "nginx:latest"
        }
    ]
    cpu    = "256"
    memory = "512"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
  }
}

# Test 2: PASS - pid_mode explicitly set to "task"
resource "aws_ecs_task_definition" "pass_pid_mode_task" {
  attrs = {
    family = "test-task-explicit"
    container_definitions = [
        {
            name = "test-container"
            image = "nginx:latest"
        }
    ]
    cpu    = "256"
    memory = "512"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    pid_mode = "task"
  }
}

# Test 3: FAIL - pid_mode set to "host"
resource "aws_ecs_task_definition" "fail_pid_mode_host" {
  expect_failure = true
  attrs = {
    family = "test-task-host"
    container_definitions = [
        {
            name = "test-container"
            image = "nginx:latest"
        }
    ]
    cpu    = "256"
    memory = "512"
    network_mode = "bridge"
    requires_compatibilities = ["EC2"]
    pid_mode = "host"
  }
}
