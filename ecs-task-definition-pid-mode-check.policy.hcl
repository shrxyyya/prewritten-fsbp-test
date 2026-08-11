# Copyright IBM Corp. 2026

# ECS task definitions should not share the host's process namespace

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-task-definition-pid-mode-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_task_definition" "pid_mode_check" {
    enforcement_level = input.ecs-task-definition-pid-mode-check-enforcement-level
    enforce {
        condition = core::try(attrs.pid_mode, "task") != "host"
        error_message = "ECS task definition has pid_mode set to 'host', which shares the host's process namespace with containers. This reduces process isolation and security. Remove the pid_mode attribute or set it to 'task' for proper isolation"
    }
}
