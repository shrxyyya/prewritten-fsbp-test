# Copyright IBM Corp. 2026

# CodeBuild Bitbucket source repository URLs should not contain sensitive credentials

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "codebuild-project-source-repo-url-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_codebuild_project" "bitbucket_credentials_check" {
    enforcement_level = input.codebuild-project-source-repo-url-check-enforcement-level
    # Filter to only Bitbucket projects
    filter = core::try(attrs.source[0].type, "") == "BITBUCKET"

    locals {
        # Extract primary source configuration
        primary_source = core::try(attrs.source[0], null)
        primary_auth_type = core::try(local.primary_source.auth.type, "")
        
        # Check if primary source has proper auth configuration
        primary_has_proper_auth = local.primary_auth_type == "CODECONNECTIONS" || local.primary_auth_type == "SECRETS_MANAGER"
        
        # Extract secondary sources
        secondary_sources = core::try(attrs.secondary_sources, [])
        
        # Check each secondary source for Bitbucket type
        bitbucket_secondary_sources = [
            for source in local.secondary_sources :
            source if core::try(source.type, "") == "BITBUCKET"
        ]
        
        # Check if any secondary source lacks proper auth
        secondary_auth_violations = [
            for source in local.bitbucket_secondary_sources :
            source if !(
                core::try(source.auth.type, "") == "CODECONNECTIONS" ||
                core::try(source.auth.type, "") == "SECRETS_MANAGER"
            )
        ]
        
        # Overall compliance check
        secondary_compliant = core::length(local.secondary_auth_violations) == 0
    }

    # Check primary source has proper authentication
    enforce {
        condition = local.primary_has_proper_auth
        error_message = "CodeBuild project must use CODECONNECTIONS or SECRETS_MANAGER authentication for Bitbucket source. Current auth type: '${local.primary_auth_type}'. Configure OAuth or AWS CodeStar Connections for secure authentication"
    }

    # Check secondary sources have proper authentication
    enforce {
        condition = local.secondary_compliant
        error_message = "CodeBuild project has ${core::length(local.secondary_auth_violations)} secondary Bitbucket source(s) without proper authentication. Configure CODECONNECTIONS or SECRETS_MANAGER authentication for all secondary sources"
    }
}
