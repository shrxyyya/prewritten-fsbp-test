# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-containers-readonly-access.policy.hcl"
    ]
}

# Test 1: PASS - Single container with readonlyRootFilesystem = true
resource "aws_ecs_task_definition" "pass_single_container_readonly_true" {
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "readonlyRootFilesystem": true
  }
]
EOT
  }
}

# Test 2: PASS - Multiple containers all with readonlyRootFilesystem = true
resource "aws_ecs_task_definition" "pass_multiple_containers_all_readonly_true" {
  attrs = {
    family = "test-task-multi"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "readonlyRootFilesystem": true
  },
  {
    "name": "sidecar-container",
    "image": "busybox:latest",
    "memory": 256,
    "cpu": 128,
    "readonlyRootFilesystem": true
  }
]
EOT
  }
}

# Test 3: FAIL - Single container with readonlyRootFilesystem = false
resource "aws_ecs_task_definition" "fail_single_container_readonly_false" {
  expect_failure = true
  attrs = {
    family = "test-task-false"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "readonlyRootFilesystem": false
  }
]
EOT
  }
}

# Test 4: FAIL - Single container missing readonlyRootFilesystem parameter
resource "aws_ecs_task_definition" "fail_single_container_missing_readonly" {
  expect_failure = true
  attrs = {
    family = "test-task-missing"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256
  }
]
EOT
  }
}

# Test 5: FAIL - Multiple containers with partial compliance
resource "aws_ecs_task_definition" "fail_multiple_containers_partial_readonly" {
  expect_failure = true
  attrs = {
    family = "test-task-partial"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "readonlyRootFilesystem": true
  },
  {
    "name": "sidecar-container",
    "image": "busybox:latest",
    "memory": 256,
    "cpu": 128,
    "readonlyRootFilesystem": false
  }
]
EOT
  }
}

# Test 6: FAIL - Multiple containers with no compliance
resource "aws_ecs_task_definition" "fail_multiple_containers_none_readonly" {
  expect_failure = true
  attrs = {
    family = "test-task-none"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "nginx:latest",
    "memory": 512,
    "cpu": 256,
    "readonlyRootFilesystem": false
  },
  {
    "name": "sidecar-container",
    "image": "busybox:latest",
    "memory": 256,
    "cpu": 128
  }
]
EOT
  }
}
