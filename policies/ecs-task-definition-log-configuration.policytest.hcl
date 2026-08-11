# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecs-task-definition-log-configuration.policy.hcl"
  ]
}

# Test 1: PASS - Single container with logging configuration
resource "aws_ecs_task_definition" "single_container_with_logging" {
  attrs = {
    family = "app"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/app",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOT
  }
}

# Test 2: FAIL - Single container without logging configuration
resource "aws_ecs_task_definition" "single_container_missing_log_configuration" {
  expect_failure = true
  attrs = {
    family = "app"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest"
  }
]
EOT
  }
}

# Test 3: FAIL - Single container with empty log driver
resource "aws_ecs_task_definition" "single_container_empty_log_driver" {
  expect_failure = true
  attrs = {
    family = "app"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "logConfiguration": {
      "logDriver": ""
    }
  }
]
EOT
  }
}

# Test 4: PASS - Multiple containers all with logging
resource "aws_ecs_task_definition" "multiple_containers_all_with_logging" {
  attrs = {
    family = "app"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "logConfiguration": {
      "logDriver": "awslogs"
    }
  },
  {
    "name": "sidecar",
    "image": "busybox:latest",
    "logConfiguration": {
      "logDriver": "fluentd"
    }
  }
]
EOT
  }
}

# Test 5: FAIL - Multiple containers, one missing logging configuration
resource "aws_ecs_task_definition" "multiple_containers_one_missing_log_configuration" {
  expect_failure = true
  attrs = {
    family = "app"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "logConfiguration": {
      "logDriver": "awslogs"
    }
  },
  {
    "name": "sidecar",
    "image": "busybox:latest"
  }
]
EOT
  }
}
