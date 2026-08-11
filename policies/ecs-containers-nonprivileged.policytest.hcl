# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-containers-nonprivileged.policy.hcl"
    ]
}

# Test 1: PASS - privileged omitted (defaults to false)
resource "aws_ecs_task_definition" "passes_when_privileged_omitted" {
  attrs = {
    family = "example-pass-omitted"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "essential": true
  }
]
EOT
  }
}

# Test 2: PASS - privileged explicitly set to false
resource "aws_ecs_task_definition" "passes_when_privileged_false" {
  attrs = {
    family = "example-pass-false"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "essential": true,
    "privileged": false
  }
]
EOT
  }
}

# Test 3: FAIL - privileged explicitly set to true
resource "aws_ecs_task_definition" "fails_when_privileged_true" {
  expect_failure = true
  attrs = {
    family = "example-fail-true"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "essential": true,
    "privileged": true
  }
]
EOT
  }
}

# Test 4: FAIL - one container privileged, others not
resource "aws_ecs_task_definition" "fails_when_any_container_privileged" {
  expect_failure = true
  attrs = {
    family = "example-fail-mixed"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "essential": true,
    "privileged": false
  },
  {
    "name": "sidecar",
    "image": "busybox:latest",
    "essential": true,
    "privileged": true
  }
]
EOT
  }
}
