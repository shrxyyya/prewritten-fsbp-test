# Copyright IBM Corp. 2026

# ECS clusters should use Container Insights

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-container-insights-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_cluster" "container_insights_enabled" {
    enforcement_level = input.ecs-container-insights-enabled-enforcement-level
    locals {
        cluster_settings = core::try(attrs.setting, [])
        container_insights_settings = [
            for setting in local.cluster_settings : setting
            if core::try(setting.name, "") == "containerInsights"
        ]
        allowed_values = ["enabled", "enhanced"]
        container_insights_disabled = [
            for setting in local.container_insights_settings : setting
            if !core::contains(local.allowed_values, core::try(setting.value, ""))
        ]
    }

    enforce {
        condition = core::length(local.container_insights_settings) > 0
        error_message = "ECS cluster must define a setting block with name 'containerInsights'"
    }

    enforce {
        condition = core::length(local.container_insights_disabled) == 0
        error_message = "ECS cluster setting 'containerInsights' must be set to 'enabled' or 'enhanced'"
    }
}
