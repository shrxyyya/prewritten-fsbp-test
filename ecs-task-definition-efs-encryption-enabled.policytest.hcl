# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-task-definition-efs-encryption-enabled.policy.hcl"
    ]
}

# Test 1: PASS - EFS volume with transit_encryption explicitly set to ENABLED
resource "aws_ecs_task_definition" "pass_efs_encryption_enabled" {
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name = "efs-volume"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-12345678"
            transit_encryption = "ENABLED"
          }
        ]
      }
    ]
  }
}

# Test 2: FAIL - EFS volume with transit_encryption explicitly set to DISABLED
resource "aws_ecs_task_definition" "fail_efs_encryption_disabled" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name = "efs-volume"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-12345678"
            transit_encryption = "DISABLED"
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - EFS volume without transit_encryption specified (defaults to DISABLED)
resource "aws_ecs_task_definition" "fail_efs_encryption_not_specified" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name = "efs-volume"
        efs_volume_configuration = [
          {
            file_system_id = "fs-12345678"
          }
        ]
      }
    ]
  }
}

# Test 4: PASS - Multiple EFS volumes all with transit_encryption ENABLED
resource "aws_ecs_task_definition" "pass_multiple_efs_all_encrypted" {
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name = "efs-volume-1"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-11111111"
            transit_encryption = "ENABLED"
          }
        ]
      },
      {
        name = "efs-volume-2"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-22222222"
            transit_encryption = "ENABLED"
          }
        ]
      }
    ]
  }
}

# Test 5: FAIL - Multiple EFS volumes with at least one having transit_encryption DISABLED
resource "aws_ecs_task_definition" "fail_multiple_efs_one_disabled" {
  expect_failure = true
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name = "efs-volume-1"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-11111111"
            transit_encryption = "ENABLED"
          }
        ]
      },
      {
        name = "efs-volume-2"
        efs_volume_configuration = [
          {
            file_system_id     = "fs-22222222"
            transit_encryption = "DISABLED"
          }
        ]
      }
    ]
  }
}

# Test 6: PASS - Task definition without EFS volumes (only non-EFS volumes)
resource "aws_ecs_task_definition" "pass_no_efs_volumes" {
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
    volume = [
      {
        name      = "docker-volume"
        host_path = "/var/lib/docker"
      }
    ]
  }
}

# Test 7: PASS - Task definition without any volume blocks
resource "aws_ecs_task_definition" "pass_no_volumes" {
  attrs = {
    family = "test-task"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx:latest\"}]"
  }
}
