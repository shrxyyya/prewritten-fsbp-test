# Copyright IBM Corp. 2026

policytest {
    targets = [
        "efs-access-point-enforce-root-directory.policy.hcl"
    ]
}

# Test 1: PASS - Access point with root_directory.path set to '/data'
resource "aws_efs_access_point" "pass_with_data_path" {
  attrs = {
    file_system_id = "fs-12345678"
    root_directory = [
      {
        path = "/data"
        creation_info = [
          {
            owner_gid = 1000
            owner_uid = 1000
            permissions = "0755"
          }
        ]
      }
    ]
    tags = {
      Name = "compliant-access-point"
    }
  }
}

# Test 2: PASS - Access point with nested subdirectory path '/app/logs'
resource "aws_efs_access_point" "pass_with_nested_path" {
  attrs = {
    file_system_id = "fs-87654321"
    root_directory = [
      {
        path = "/app/logs"
        creation_info = [
          {
            owner_gid = 2000
            owner_uid = 2000
            permissions = "0750"
          }
        ]
      }
    ]
    posix_user = [
      {
        gid = 2000
        uid = 2000
      }
    ]
  }
}

# Test 3: PASS - Access point with maximum depth path (4 subdirectories)
resource "aws_efs_access_point" "pass_with_max_depth_path" {
  attrs = {
    file_system_id = "fs-11223344"
    root_directory = [
      {
        path = "/level1/level2/level3/level4"
        creation_info = [
          {
            owner_gid = 3000
            owner_uid = 3000
            permissions = "0755"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - Access point with root_directory.path explicitly set to '/'
resource "aws_efs_access_point" "fail_with_root_slash" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-99887766"
    root_directory = [
      {
        path = "/"
      }
    ]
    tags = {
      Name = "non-compliant-root"
    }
  }
}

# Test 5: FAIL - Access point without root_directory block (defaults to '/')
resource "aws_efs_access_point" "fail_without_root_directory" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-55443322"
    posix_user = [
      {
        gid = 1000
        uid = 1000
      }
    ]
    tags = {
      Name = "non-compliant-no-root-dir"
    }
  }
}

# Test 6: FAIL - Access point with empty path string
resource "aws_efs_access_point" "fail_with_empty_path" {
  expect_failure = true
  attrs = {
    file_system_id = "fs-66778899"
    root_directory = [
      {
        path = ""
      }
    ]
  }
}
