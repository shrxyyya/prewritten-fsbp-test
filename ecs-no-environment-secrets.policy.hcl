# Copyright IBM Corp. 2026

# Secrets should not be passed as container environment variables

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecs-no-environment-secrets-enforcement-level" {
  type = string
  default = "advisory"
}

input "secret_keys" {
    type = string
    default = "AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,ECS_ENGINE_AUTH_DATA"
}

resource_policy "aws_ecs_task_definition" "no_environment_secrets" {
    enforcement_level = input.ecs-no-environment-secrets-enforcement-level
    # Only check task definitions that have container_definitions
    filter = attrs.container_definitions != null

    locals {
        containers = core::jsondecode(attrs.container_definitions)
        
        prohibited_vars = core::split(",", input.secret_keys)
        
        violations = [
            for container in local.containers :
            {
                container_name = container.name
                prohibited_found = [
                    # environment = array of keyvalue pairs => {name, value}
                    for env_var in core::try(container.environment, []) : env_var.name
                    if core::contains(local.prohibited_vars, env_var.name)
                ]
            }
            if core::length(core::try(container.environment, [])) > 0
        ]
        
        # Filter to only containers with actual violations
        containers_with_violations = [
            for v in local.violations : v
            if core::length(v.prohibited_found) > 0
        ]
        
        has_violations = core::length(local.containers_with_violations) > 0
    }

    enforce {
        condition = core::length(local.containers_with_violations) == 0
        error_message = "Task definition contains prohibited environment variables in containers. Use the 'secrets' parameter to reference AWS Secrets Manager or Systems Manager Parameter Store instead of passing secrets as environment variables"
    }
}
