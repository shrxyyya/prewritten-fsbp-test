# Copyright IBM Corp. 2026

# EFS access points should enforce a user identity

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "efs-access-point-enforce-user-identity-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_efs_access_point" "enforce_user_identity" {
    enforcement_level = input.efs-access-point-enforce-user-identity-enforcement-level
    locals {
        posix_user_block = core::try(attrs.posix_user[0], null)

        has_posix_user = local.posix_user_block != null
        uid            = core::try(local.posix_user_block.uid, null)
        gid            = core::try(local.posix_user_block.gid, null)
    }

    enforce {
        condition     = local.has_posix_user
        error_message = "EFS access point must define a posix_user block to enforce user identity (EFS.4). Add a posix_user block with uid and gid"
    }

    enforce {
        condition     = !local.has_posix_user || (local.uid != null && local.gid != null)
        error_message = "EFS access point configuration is missing required uid and/or gid values in the posix_user block. Both must be set to enforce user identity (EFS.4)"
    }
}
