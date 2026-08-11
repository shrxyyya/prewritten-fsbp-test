# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecs-task-definition-linux-user-non-root.policy.hcl"
  ]
}

# Pass Case 1: Container with non-root user (UID format)
resource "aws_ecs_task_definition" "pass_nonroot_uid" {
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "1000"
      }
    ]
  }
}

# Pass Case 2: Container with non-root username
resource "aws_ecs_task_definition" "pass_nonroot_username" {
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "appuser"
      }
    ]
  }
}

# Pass Case 3: Container with username:group format
resource "aws_ecs_task_definition" "pass_username_group" {
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "appuser:appgroup"
      }
    ]
  }
}

# Pass Case 4: Container with UID:GID format
resource "aws_ecs_task_definition" "pass_uid_gid" {
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "1000:1000"
      }
    ]
  }
}

# Pass Case 5: Multiple containers all with non-root users
resource "aws_ecs_task_definition" "pass_multiple_containers_compliant" {
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "appuser"
      },
      {
        name      = "sidecar-container"
        image     = "busybox:latest"
        cpu       = 128
        memory    = 256
        essential = false
        user      = "1000"
      }
    ]
  }
}

# Fail Case 1: Container with missing user parameter
resource "aws_ecs_task_definition" "fail_missing_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
      }
    ]
  }
}

# Fail Case 2: Container configured with user='root'
resource "aws_ecs_task_definition" "fail_root_username" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "root"
      }
    ]
  }
}

# Fail Case 3: Container configured with user='0' (root UID)
resource "aws_ecs_task_definition" "fail_root_uid" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "0"
      }
    ]
  }
}

# Fail Case 4: Multiple containers where one is missing user parameter
resource "aws_ecs_task_definition" "fail_multiple_one_missing_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "appuser"
      },
      {
        name      = "sidecar-container"
        image     = "busybox:latest"
        cpu       = 128
        memory    = 256
        essential = false
      }
    ]
  }
}

# Fail Case 5: Multiple containers where one is configured as root
resource "aws_ecs_task_definition" "fail_multiple_one_root" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
        user      = "appuser"
      },
      {
        name      = "sidecar-container"
        image     = "busybox:latest"
        cpu       = 128
        memory    = 256
        essential = false
        user      = "root"
      }
    ]
  }
}

# Filter Test 1: Windows task definition should be filtered out (not evaluated)
resource "aws_ecs_task_definition" "filter_windows_excluded" {
  attrs = {
    family = "test-task"
    runtime_platform = [
      {
        operating_system_family = "WINDOWS_SERVER_2019_CORE"
        cpu_architecture        = "X86_64"
      }
    ]
    container_definitions = [
      {
        name      = "app-container"
        image     = "mcr.microsoft.com/windows/servercore:ltsc2019"
        cpu       = 256
        memory    = 512
        essential = true
      }
    ]
  }
}

# Filter Test 2: Task definition without runtime_platform (defaults to Linux) should fail without user
resource "aws_ecs_task_definition" "filter_default_linux_evaluated" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = [
      {
        name      = "app-container"
        image     = "nginx:latest"
        cpu       = 256
        memory    = 512
        essential = true
      }
    ]
  }
}
