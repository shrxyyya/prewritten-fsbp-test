# Copyright IBM Corp. 2026

policytest {
  targets = ["beanstalk-enhanced-health-reporting-enabled.policy.hcl"]
}

# Test 1: PASS - Enhanced health reporting enabled
resource "aws_elastic_beanstalk_environment" "pass_enhanced_enabled" {
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:healthreporting:system"
        name      = "SystemType"
        value     = "enhanced"
      }
    ]
  }
}

# Test 2: FAIL - Basic health reporting (not enhanced)
resource "aws_elastic_beanstalk_environment" "fail_basic_health_reporting" {
  expect_failure = true
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:healthreporting:system"
        name      = "SystemType"
        value     = "basic"
      }
    ]
  }
}

# Test 3: FAIL - No health reporting configuration
resource "aws_elastic_beanstalk_environment" "fail_no_health_reporting_config" {
  expect_failure = true
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "ENV_VAR"
        value     = "some_value"
      }
    ]
  }
}

# Test 4: FAIL - Empty settings list
resource "aws_elastic_beanstalk_environment" "fail_empty_settings" {
  expect_failure = true
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting     = []
  }
}

# Test 5: PASS - Multiple settings with enhanced health reporting
resource "aws_elastic_beanstalk_environment" "pass_multiple_settings_with_enhanced" {
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "ENV_VAR"
        value     = "some_value"
      },
      {
        namespace = "aws:elasticbeanstalk:healthreporting:system"
        name      = "SystemType"
        value     = "enhanced"
      },
      {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "InstanceType"
        value     = "t2.micro"
      }
    ]
  }
}

# Test 6: FAIL - Wrong namespace
resource "aws_elastic_beanstalk_environment" "fail_wrong_namespace" {
  expect_failure = true
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:monitoring"
        name      = "SystemType"
        value     = "enhanced"
      }
    ]
  }
}

# Test 7: FAIL - Wrong setting name
resource "aws_elastic_beanstalk_environment" "fail_wrong_setting_name" {
  expect_failure = true
  attrs = {
    name        = "my-environment"
    application = "my-app"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:healthreporting:system"
        name      = "HealthCheckType"
        value     = "enhanced"
      }
    ]
  }
}