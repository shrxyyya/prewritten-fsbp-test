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

resource "aws_backup_vault" "example" {
  name = "example-efs-backup-vault"
}

resource "aws_backup_plan" "example" {
  name = "example-efs-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.example.name
    schedule          = "cron(0 5 ? * * *)"
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_efs_file_system" "example" {
  encrypted = true
}

resource "aws_backup_selection" "example" {
  iam_role_arn = "arn:aws:iam::123456789012:role/example-backup-role"
  name         = "example-efs-selection"
  plan_id      = aws_backup_plan.example.id

  resources = [aws_efs_file_system.example.arn]
}

resource "aws_efs_backup_policy" "example" {
  file_system_id = aws_efs_file_system.example.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_access_point" "example" {
  file_system_id = aws_efs_file_system.example.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/app"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id  = aws_efs_file_system.example.id
  subnet_id       = aws_subnet.example.id
  security_groups = []
}
