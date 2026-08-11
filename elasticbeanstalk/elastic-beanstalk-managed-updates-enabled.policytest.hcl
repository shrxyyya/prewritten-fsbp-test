# Copyright IBM Corp. 2026

policytest {
    targets = ["elastic-beanstalk-managed-updates-enabled.policy.hcl"]
}

# Test 1: PASS - Environment with managed updates enabled
resource "aws_elastic_beanstalk_environment" "pass_managed_updates_enabled" {
    attrs = {
        name = "test-environment"
        application = "test-app"
        solution_stack_name = "64bit Amazon Linux 2 v5.8.0 running Node.js 18"
        
        setting = [
            {
                namespace = "aws:elasticbeanstalk:managedactions"
                name = "ManagedActionsEnabled"
                value = "true"
            },
            {
                namespace = "aws:elasticbeanstalk:managedactions"
                name = "PreferredStartTime"
                value = "Sun:10:00"
            },
            {
                namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
                name = "UpdateLevel"
                value = "patch"
            }
        ]
    }
}

# Test 2: PASS - Environment with managed updates and update level
resource "aws_elastic_beanstalk_environment" "pass_managed_updates_with_level" {
    attrs = {
        name = "prod-environment"
        application = "prod-app"
        solution_stack_name = "64bit Amazon Linux 2 v5.8.0 running Node.js 18"
        
        setting = [
            {
                namespace = "aws:elasticbeanstalk:managedactions"
                name = "ManagedActionsEnabled"
                value = "true"
            },
            {
                namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
                name = "UpdateLevel"
                value = "minor"
            }
        ]
    }
}

# Test 3: FAIL - Environment without managed updates configuration
resource "aws_elastic_beanstalk_environment" "fail_no_managed_updates" {
    expect_failure = true
    
    attrs = {
        name = "test-environment-no-updates"
        application = "test-app"
        solution_stack_name = "64bit Amazon Linux 2 v5.8.0 running Node.js 18"
        
        setting = [
            {
                namespace = "aws:autoscaling:launchconfiguration"
                name = "InstanceType"
                value = "t3.micro"
            }
        ]
    }
}

# Test 4: FAIL - Environment with managed updates explicitly disabled
resource "aws_elastic_beanstalk_environment" "fail_managed_updates_disabled" {
    expect_failure = true
    
    attrs = {
        name = "test-environment-disabled"
        application = "test-app"
        solution_stack_name = "64bit Amazon Linux 2 v5.8.0 running Node.js 18"
        
        setting = [
            {
                namespace = "aws:elasticbeanstalk:managedactions"
                name = "ManagedActionsEnabled"
                value = "false"
            }
        ]
    }
}

# Test 5: FAIL - Environment with empty settings
resource "aws_elastic_beanstalk_environment" "fail_empty_settings" {
    expect_failure = true
    
    attrs = {
        name = "test-environment-empty"
        application = "test-app"
        solution_stack_name = "64bit Amazon Linux 2 v5.8.0 running Node.js 18"
        
        setting = []
    }
}
