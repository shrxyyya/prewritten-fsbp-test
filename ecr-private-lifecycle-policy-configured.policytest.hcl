# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ecr-private-lifecycle-policy-configured.policy.hcl"
  ]
}
# Test 1: Pass - ECR repository with lifecycle policy configured
resource "aws_ecr_repository" "compliant" {
  attrs = {
    name = "my-app-repo"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration = [{
      scan_on_push = true
    }]
    encryption_configuration = [{
      encryption_type = "AES256"
    }]
    force_delete = false
    tags = {
      Environment = "production"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "compliant_policy" {
  attrs = {
    repository = "my-app-repo"
    policy = "{\"rules\":[{\"rulePriority\":1,\"description\":\"Expire untagged images older than 14 days\",\"selection\":{\"tagStatus\":\"untagged\",\"countType\":\"sinceImagePushed\",\"countUnit\":\"days\",\"countNumber\":14},\"action\":{\"type\":\"expire\"}}]}"
  }
}

# Test 2: Fail - ECR repository without lifecycle policy
resource "aws_ecr_repository" "non_compliant" {
  expect_failure = true
  attrs = {
    name = "my-app-repo-no-policy"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration = [{
      scan_on_push = true
    }]
    encryption_configuration = [{
      encryption_type = "AES256"
    }]
    force_delete = false
    tags = {
      Environment = "development"
    }
  }
}

# Test 3: Pass - Another compliant repository
resource "aws_ecr_repository" "compliant_repo" {
  attrs = {
    name = "compliant-repo"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration = [{
      scan_on_push = true
    }]
    encryption_configuration = [{
      encryption_type = "KMS"
      kms_key = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }]
    force_delete = false
    tags = {
      Environment = "production"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "compliant_repo_policy" {
  attrs = {
    repository = "compliant-repo"
    policy = "{\"rules\":[{\"rulePriority\":1,\"description\":\"Keep last 10 images\",\"selection\":{\"tagStatus\":\"any\",\"countType\":\"imageCountMoreThan\",\"countNumber\":10},\"action\":{\"type\":\"expire\"}}]}"
  }
}

# Test 4: Fail - Another non-compliant repository
resource "aws_ecr_repository" "non_compliant_repo" {
  expect_failure = true
  attrs = {
    name = "non-compliant-repo"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration = [{
      scan_on_push = false
    }]
    encryption_configuration = [{
      encryption_type = "AES256"
    }]
    force_delete = false
    tags = {
      Environment = "staging"
    }
  }
}

# Test 5: Pass - Repository with complex lifecycle policy
resource "aws_ecr_repository" "complex_repo" {
  attrs = {
    name = "complex-repo"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration = [{
      scan_on_push = true
    }]
    encryption_configuration = [{
      encryption_type = "AES256"
    }]
    force_delete = false
    tags = {
      Environment = "production"
      Team = "platform"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "complex_policy" {
  attrs = {
    repository = "complex-repo"
    policy = "{\"rules\":[{\"rulePriority\":1,\"description\":\"Expire untagged images older than 7 days\",\"selection\":{\"tagStatus\":\"untagged\",\"countType\":\"sinceImagePushed\",\"countUnit\":\"days\",\"countNumber\":7},\"action\":{\"type\":\"expire\"}},{\"rulePriority\":2,\"description\":\"Keep only last 20 tagged images\",\"selection\":{\"tagStatus\":\"tagged\",\"tagPrefixList\":[\"v\"],\"countType\":\"imageCountMoreThan\",\"countNumber\":20},\"action\":{\"type\":\"expire\"}}]}"
  }
}