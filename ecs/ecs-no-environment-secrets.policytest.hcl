# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecs-no-environment-secrets.policy.hcl"
  ]
}

# Test 1: PASS - No environment variables
resource "aws_ecs_task_definition" "pass_no_env_vars" {
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true
  }
]
EOT
  }
}

# Test 2: PASS - Safe environment variables
resource "aws_ecs_task_definition" "pass_safe_env_vars" {
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "APP_ENV",
        "value": "production"
      },
      {
        "name": "LOG_LEVEL",
        "value": "info"
      }
    ]
  }
]
EOT
  }
}

# Test 3: PASS - Using secrets parameter instead
resource "aws_ecs_task_definition" "pass_using_secrets" {
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "secrets": [
      {
        "name": "DB_PASSWORD",
        "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password"
      }
    ]
  }
]
EOT
  }
}

# Test 4: FAIL - AWS_ACCESS_KEY_ID in environment
resource "aws_ecs_task_definition" "fail_aws_access_key_id" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "AKIAIOSFODNN7EXAMPLE"
      }
    ]
  }
]
EOT
  }
}

# Test 5: FAIL - AWS_SECRET_ACCESS_KEY in environment
resource "aws_ecs_task_definition" "fail_aws_secret_access_key" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "value": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      }
    ]
  }
]
EOT
  }
}

# Test 6: FAIL - ECS_ENGINE_AUTH_DATA in environment
resource "aws_ecs_task_definition" "fail_ecs_engine_auth_data" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "ECS_ENGINE_AUTH_DATA",
        "value": "sometestvalue"
      }
    ]
  }
]
EOT
  }
}

# Test 7: FAIL - Multiple prohibited variables
resource "aws_ecs_task_definition" "fail_multiple_prohibited" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "AKIAIOSFODNN7EXAMPLE"
      },
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "value": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      }
    ]
  }
]
EOT
  }
}

# Test 8: FAIL - Multiple containers, one with prohibited variables
resource "aws_ecs_task_definition" "fail_multiple_containers" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app",
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "APP_ENV",
        "value": "production"
      }
    ]
  },
  {
    "name": "sidecar",
    "image": "datadog/agent:latest",
    "cpu": 128,
    "memory": 256,
    "essential": false,
    "environment": [
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "AKIAIOSFODNN7EXAMPLE"
      }
    ]
  }
]
EOT
  }
}
