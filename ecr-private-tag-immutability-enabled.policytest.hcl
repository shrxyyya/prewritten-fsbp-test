# Copyright IBM Corp. 2026

policytest {
  targets = ["ecr-private-tag-immutability-enabled.policy.hcl"]
}

resource "aws_ecr_repository" "immutable_pass" {
  attrs = {
    name                 = "immutable-pass"
    image_tag_mutability = "IMMUTABLE"
  }
}

resource "aws_ecr_repository" "mutable_fail" {
  expect_failure = true
  attrs = {
    name                 = "mutable-fail"
    image_tag_mutability = "MUTABLE"
  }
}

resource "aws_ecr_repository" "immutable_with_exclusion_fail" {
  expect_failure = true
  attrs = {
    name                 = "immutable-with-exclusion-fail"
    image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  }
}

resource "aws_ecr_repository" "missing_mutability_fail" {
  expect_failure = true
  attrs = {
    name = "missing-mutability-fail"
  }
}
