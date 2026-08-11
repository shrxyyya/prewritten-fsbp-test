# Copyright IBM Corp. 2026

# ECS Fargate services should run on the latest Fargate platform version

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-fargate-latest-platform-version-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecs_service" "fargate_latest_platform" {
    enforcement_level = input.ecs-fargate-latest-platform-version-enforcement-level
    filter = attrs.launch_type == "FARGATE"

    locals {
        latest_linux_version = "1.4.0"
        latest_windows_version = "1.0.0"
        platform_version = core::try(attrs.platform_version, "LATEST")

        is_explicit_latest = local.platform_version == local.latest_linux_version || local.platform_version == local.latest_windows_version
    }

    enforce {
        condition = local.platform_version == "LATEST" || local.is_explicit_latest
        error_message = "ECS Fargate service is not using the latest platform version"
    }
}
