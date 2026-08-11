# Copyright IBM Corp. 2026

# ECR repositories should have at least one lifecycle policy configured

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ecr-private-lifecycle-policy-configured-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ecr_repository" "lifecycle_policy_required" {
    enforcement_level = input.ecr-private-lifecycle-policy-configured-enforcement-level
    locals {
        # Get the repository name for this resource
        repository_name = core::try(attrs.name, "")

        # Query lifecycle policies that reference this repository directly
        # using the filter in core::getresources.
        matching_policies = core::getresources("aws_ecr_lifecycle_policy", {
            repository = local.repository_name
        })

        # Check if at least one lifecycle policy exists for this repository
        has_lifecycle_policy = core::length(local.matching_policies) > 0
    }

    enforce {
        condition = local.has_lifecycle_policy
        error_message = "ECR repository '${local.repository_name}' must have at least one lifecycle policy configured. Add an 'aws_ecr_lifecycle_policy' resource that references this repository to enable automated image cleanup and comply with ECR.3"
    }
}
