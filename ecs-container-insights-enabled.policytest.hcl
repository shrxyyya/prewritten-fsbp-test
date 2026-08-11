# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ecs-container-insights-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Container Insights is enabled
resource "aws_ecs_cluster" "container_insights_enabled" {
  attrs = {
    name = "ecs-cluster-enabled"
    setting = [
      {
        name  = "containerInsights"
        value = "enabled"
      }
    ]
  }
}

# Test 2: PASS - Container Insights is enhanced
resource "aws_ecs_cluster" "container_insights_enhanced" {
  attrs = {
    name = "ecs-cluster-enhanced"
    setting = [
      {
        name  = "containerInsights"
        value = "enhanced"
      }
    ]
  }
}

# Test 3: FAIL - Container Insights is missing
resource "aws_ecs_cluster" "missing_container_insights_setting" {
  expect_failure = true
  attrs = {
    name = "ecs-cluster-missing-setting"
    setting = [
      {
        name  = "otherSetting"
        value = "enabled"
      }
    ]
  }
}

# Test 4: FAIL - Container Insights is disabled
resource "aws_ecs_cluster" "container_insights_disabled" {
  expect_failure = true
  attrs = {
    name = "ecs-cluster-disabled"
    setting = [
      {
        name  = "containerInsights"
        value = "disabled"
      }
    ]
  }
}
