# Copyright IBM Corp. 2026

policytest {
  targets = [
    "custom-eventbus-policy-attached.policy.hcl"
  ]
}
resource "aws_cloudwatch_event_bus" "custom_with_policy" {
  attrs = {
    name = "custom-event-bus"
  }
}

resource "aws_cloudwatch_event_bus_policy" "valid_policy" {
  attrs = {
    event_bus_name = "custom-event-bus"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:root\"},\"Action\":\"events:PutEvents\",\"Resource\":\"arn:aws:events:us-east-1:123456789012:event-bus/custom-event-bus\"}]}"
  }
}

# Test 2: FAIL - Custom event bus without any resource-based policy
resource "aws_cloudwatch_event_bus" "custom_without_policy" {
  expect_failure = true
  attrs = {
    name = "unprotected-event-bus"
  }
}

# Test 3: FAIL - Custom event bus with empty policy document
resource "aws_cloudwatch_event_bus" "custom_with_empty_policy" {
  expect_failure = true
  attrs = {
    name = "bus-with-empty-policy"
  }
}

resource "aws_cloudwatch_event_bus_policy" "empty_policy" {
  attrs = {
    event_bus_name = "bus-with-empty-policy"
    policy = ""
  }
}

# Test 4: PASS - Default event bus without policy (should be filtered out)
resource "aws_cloudwatch_event_bus" "default_bus" {
  attrs = {
    name = "default"
  }
}

# Test 5: PASS - Custom event bus with policy that defaults to "default" event_bus_name
# This tests the edge case where event_bus_name is omitted in the policy resource
resource "aws_cloudwatch_event_bus" "another_custom_bus" {
  attrs = {
    name = "production-events"
  }
}

resource "aws_cloudwatch_event_bus_policy" "policy_for_production" {
  attrs = {
    event_bus_name = "production-events"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"events.amazonaws.com\"},\"Action\":\"events:PutEvents\",\"Resource\":\"*\"}]}"
  }
}

# Test 6: FAIL - Multiple custom buses, one without policy
resource "aws_cloudwatch_event_bus" "compliant_bus" {
  attrs = {
    name = "compliant-bus"
  }
}

resource "aws_cloudwatch_event_bus_policy" "compliant_policy" {
  attrs = {
    event_bus_name = "compliant-bus"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"events:*\",\"Resource\":\"*\",\"Condition\":{\"StringNotEquals\":{\"aws:PrincipalOrgID\":\"o-123456789\"}}}]}"
  }
}

resource "aws_cloudwatch_event_bus" "non_compliant_bus" {
  expect_failure = true
  attrs = {
    name = "non-compliant-bus"
  }
}
