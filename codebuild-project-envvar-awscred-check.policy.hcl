# Copyright IBM Corp. 2026

# CodeBuild project environment variables should not contain clear text credentials

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "codebuild-project-envvar-awscred-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_codebuild_project" "no_plaintext_credentials" {
    enforcement_level = input.codebuild-project-envvar-awscred-check-enforcement-level
    # Filter to only check projects that have environment variables defined
    filter = attrs.environment != null && core::length(attrs.environment) > 0 && core::try(attrs.environment[0].environment_variable, null) != null && core::length(core::try(attrs.environment[0].environment_variable, [])) > 0

    locals {
        # Extract environment variables from the environment block
        env_vars = core::try(attrs.environment[0].environment_variable, [])
        
        # Find any plaintext AWS credential variables
        plaintext_access_key_vars = [
            for var in local.env_vars :
            var if var.name == "AWS_ACCESS_KEY_ID" && 
                   (core::try(var.type, "PLAINTEXT") == "PLAINTEXT")
        ]
        
        plaintext_secret_key_vars = [
            for var in local.env_vars :
            var if var.name == "AWS_SECRET_ACCESS_KEY" && 
                   (core::try(var.type, "PLAINTEXT") == "PLAINTEXT")
        ]
        
        # Check if any plaintext credentials exist
        has_plaintext_access_key = core::length(local.plaintext_access_key_vars) > 0
        has_plaintext_secret_key = core::length(local.plaintext_secret_key_vars) > 0
    }

    # Enforce: No plaintext AWS_ACCESS_KEY_ID
    enforce {
        condition = !local.has_plaintext_access_key
        error_message = "CodeBuild project contains AWS_ACCESS_KEY_ID as a plaintext environment variable. Store credentials in AWS Systems Manager Parameter Store (type: PARAMETER_STORE) or AWS Secrets Manager (type: SECRETS_MANAGER) instead"
    }

    # Enforce: No plaintext AWS_SECRET_ACCESS_KEY
    enforce {
        condition = !local.has_plaintext_secret_key
        error_message = "CodeBuild project contains AWS_SECRET_ACCESS_KEY as a plaintext environment variable. Store credentials in AWS Systems Manager Parameter Store (type: PARAMETER_STORE) or AWS Secrets Manager (type: SECRETS_MANAGER) instead"
    }
}
