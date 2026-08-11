# Copyright IBM Corp. 2026

policytest {
  targets = [
    "efs-access-point-enforce-user-identity.policy.hcl"
  ]
}
# Test 1: PASS - Complete posix_user with uid and gid
resource "aws_efs_access_point" "pass_complete_posix_user" {
  attrs = {
    file_system_id = "fs-12345678"
    posix_user = [
      {
        uid = 1000
        gid = 1000
      }
    ]
  }
}

# Test 2: PASS - Complete posix_user with uid, gid, and optional secondary_gids
resource "aws_efs_access_point" "pass_with_secondary_gids" {
  attrs = {
    file_system_id = "fs-12345678"
    posix_user = [
      {
        uid = 1001
        gid = 1001
        secondary_gids = [1002, 1003]
      }
    ]
  }
}

# Test 3: FAIL - Missing posix_user block entirely
resource "aws_efs_access_point" "fail_missing_posix_user" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    root_directory = [
      {
        path = "/data"
      }
    ]
  }
}

# Test 4: FAIL - posix_user block exists but missing uid
resource "aws_efs_access_point" "fail_missing_uid" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    posix_user = [
      {
        gid = 1000
      }
    ]
  }
}

# Test 5: FAIL - posix_user block exists but missing gid
resource "aws_efs_access_point" "fail_missing_gid" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    posix_user = [
      {
        uid = 1000
      }
    ]
  }
}

# Test 6: FAIL - Empty posix_user block
resource "aws_efs_access_point" "fail_empty_posix_user" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-12345678"
    posix_user = []
  }
}