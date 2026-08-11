# Copyright IBM Corp. 2026

# EFS access points should enforce a root directory

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-access-point-enforce-root-directory-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_efs_access_point" "enforce_root_directory" {
    enforcement_level = input.efs-access-point-enforce-root-directory-enforcement-level
    locals {
        root_directory = core::try(attrs.root_directory, [])
        has_root_directory = core::length(local.root_directory) > 0
        
        # Extract the path value, default to "/" if not configured
        root_path = local.has_root_directory ? core::try(local.root_directory[0].path, "/") : "/"
    }

    enforce {
        condition = local.root_path != "/" && local.root_path != ""
        error_message = "EFS access point does not enforce a root directory. The root_directory.path must be a subdirectory path (e.g., '/data', '/app', '/users') to restrict data access. Configure root_directory.path to a value other than '/' to pass this control"
    }
}
