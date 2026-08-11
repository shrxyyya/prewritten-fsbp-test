# Copyright IBM Corp. 2026

# ECR private repositories should have tag immutability configured

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecr-private-tag-immutability-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecr_repository" "tag_immutability_required" {
  enforcement_level = input.ecr-private-tag-immutability-enabled-enforcement-level
  locals {
    image_tag_mutability = core::try(attrs.image_tag_mutability, "MUTABLE")
  }

  enforce {
    condition = local.image_tag_mutability == "IMMUTABLE"
    error_message = "ECR repository must set image_tag_mutability to \"IMMUTABLE\". Found '${local.image_tag_mutability}' for resource"
  }
}
