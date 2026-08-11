# Copyright IBM Corp. 2026

policytest {
    targets = ["elastic-beanstalk-managed-updates-enabled.policy.hcl"]
    
}
inputs  {
        UpdateLevel = "patch"
}

# FAIL - Managed updates enabled but UpdateLevel does not match configured input
resource "aws_elastic_beanstalk_environment" "fail_update_level_mismatch" {
    expect_failure = true

    attrs = {
        name = "test-environment-mismatch"
        application = "test-app"
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
