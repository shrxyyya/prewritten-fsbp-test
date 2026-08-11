# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecr-private-image-scanning-enabled.policy.hcl"
  ]
}

# Pass case: ECR repository with scan_on_push enabled
resource "aws_ecr_repository" "compliant" {
  attrs = {
    name = "compliant-repo"
    image_scanning_configuration = [
      {
        scan_on_push = true
      }
    ]
  }
}

# Fail case: ECR repository without image_scanning_configuration
resource "aws_ecr_repository" "non_compliant" {
  expect_failure = true
  attrs = {
    name = "non-compliant-repo"
  }
}

# Fail case: ECR repository with scan_on_push disabled
resource "aws_ecr_repository" "disabled_scanning" {
  expect_failure = true
  attrs = {
    name = "disabled-scanning-repo"
    image_scanning_configuration = [
      {
        scan_on_push = false
      }
    ]
  }
}
