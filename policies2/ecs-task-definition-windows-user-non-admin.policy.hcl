# Copyright IBM Corp. 2026

# ECS Task Definitions should configure non-administrator users in Windows container definitions

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-task-definition-windows-user-non-admin-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "windows_non_admin_user" {
  enforcement_level = input.ecs-task-definition-windows-user-non-admin-enforcement-level
  
  locals {
    os_family = core::try(attrs.runtime_platform[0].operating_system_family, "")

    # Supported Windows OS families for ECS task definitions
    windows_os_families = [
      "WINDOWS_SERVER_2019_CORE",
      "WINDOWS_SERVER_2019_FULL",
      "WINDOWS_SERVER_2022_CORE",
      "WINDOWS_SERVER_2022_FULL",
      "WINDOWS_SERVER_2016_FULL",
    ]

    # Check if it's a Windows OS family
    is_windows = core::contains(local.windows_os_families, local.os_family)

    # Per spec: evaluate if Windows OR if operating_system_family not configured
    should_evaluate = local.is_windows || local.os_family == ""
  }

  # Only evaluate Windows task definitions or those without OS family specified
  filter = local.should_evaluate

  locals {
    # container_definitions attribute - access directly as structured data
    # In tfpolicy, this attribute is already parsed, not a JSON string
    containers = core::jsondecode(attrs.container_definitions)
    
    # Find containers without user parameter configured
    containers_without_user = [
      for container in local.containers :
      core::try(container.name, "unnamed") 
      if core::try(container.user, null) == null || core::try(container.user, "") == ""
    ]
    
    # Find containers with administrator user
    containers_with_admin = [
      for container in local.containers :
      core::try(container.name, "unnamed")
      if core::try(container.user, "") == "containeradministrator"
    ]
    
    has_user_violations = core::length(local.containers_without_user) > 0
    has_admin_violations = core::length(local.containers_with_admin) > 0
  }

  enforce {
    condition = !local.has_user_violations
    error_message = "Task definition has Windows containers without 'user' parameter configured: ${core::join(", ", local.containers_without_user)}. All Windows containers must specify a non-administrator user"
  }

  enforce {
    condition = !local.has_admin_violations
    error_message = "Task definition has Windows containers configured with default administrator user 'containeradministrator': ${core::join(", ", local.containers_with_admin)}. Windows containers must not run as administrator"
  }
}
