terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_backup_framework" "example" {
  name = "example-backup-framework"

  # backup-recovery-point-encrypted: must include BACKUP_RECOVERY_POINT_ENCRYPTED control
  control {
    name = "BACKUP_RECOVERY_POINT_ENCRYPTED"
  }
}
