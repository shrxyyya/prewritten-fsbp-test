# Copyright IBM Corp. 2026

# Test cases for ECS.21 - Windows Non-Administrator User Policy
# Generated from GWT scenarios in gwt.json

policytest {
  targets = ["ecs-task-definition-windows-user-non-admin.policy.hcl"]
}

# PASS: Windows Server 2022 Core with non-admin user
resource "aws_ecs_task_definition" "pass_windows_2022_core_with_custom_user" {
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2022_CORE"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2022",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "user": "customuser"
  }
]
EOT
  }
}

# FAIL: Windows Server 2019 Full without user parameter
resource "aws_ecs_task_definition" "fail_windows_2019_full_missing_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2019_FULL"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2019",
    "cpu": 256,
    "memory": 512,
    "essential": true
  }
]
EOT
  }
}

# FAIL: Windows Server 2022 Full with containeradministrator
resource "aws_ecs_task_definition" "fail_windows_2022_full_with_admin_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2022_FULL"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2022",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "user": "containeradministrator"
  }
]
EOT
  }
}

# FAIL: Windows Server 2019 Core with multiple containers, one missing user
resource "aws_ecs_task_definition" "fail_windows_2019_core_multiple_one_missing_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2019_CORE"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2019",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "user": "appuser"
  },
  {
    "name": "sidecar-container",
    "image": "mcr.microsoft.com/windows/nanoserver:ltsc2019",
    "cpu": 128,
    "memory": 256,
    "essential": false
  }
]
EOT
  }
}

# FAIL: Windows Server 2022 Core with multiple containers, one using admin
resource "aws_ecs_task_definition" "fail_windows_2022_core_multiple_one_admin" {
  expect_failure = true
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2022_CORE"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2022",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "user": "appuser"
  },
  {
    "name": "admin-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2022",
    "cpu": 128,
    "memory": 256,
    "essential": false,
    "user": "containeradministrator"
  }
]
EOT
  }
}

# FAIL: No runtime_platform specified, container without user
resource "aws_ecs_task_definition" "fail_no_runtime_platform_missing_user" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2022",
    "cpu": 256,
    "memory": 512,
    "essential": true
  }
]
EOT
  }
}

# PASS: Windows Server 2016 Full with all containers having non-admin users
resource "aws_ecs_task_definition" "pass_windows_2016_full_all_custom_users" {
  attrs = {
    family = "test-task"
    runtime_platform = [{
      operating_system_family = "WINDOWS_SERVER_2016_FULL"
      cpu_architecture = "X86_64"
    }]
    container_definitions = <<EOT
[
  {
    "name": "app-container",
    "image": "mcr.microsoft.com/windows/servercore:ltsc2016",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "user": "appuser"
  },
  {
    "name": "sidecar-container",
    "image": "mcr.microsoft.com/windows/nanoserver:sac2016",
    "cpu": 128,
    "memory": 256,
    "essential": false,
    "user": "sidecaruser"
  }
]
EOT
  }
}
