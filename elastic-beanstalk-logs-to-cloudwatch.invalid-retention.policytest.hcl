# Copyright IBM Corp. 2026

policytest {
  targets = ["elastic-beanstalk-logs-to-cloudwatch.policy.hcl"]
  
}
inputs {
    RetentionInDays = "45"
  }

# FAIL - Invalid RetentionInDays input value (not in allowed set)
resource "aws_elastic_beanstalk_environment" "fail_with_invalid_retention_input" {
  expect_failure = true
  attrs = {
    name = "my-environment"
    application = "my-app"
    solution_stack_name = "64bit Amazon Linux 2 v3.4.0 running Python 3.8"
    setting = [
      {
        namespace = "aws:elasticbeanstalk:cloudwatch:logs"
        name = "StreamLogs"
        value = "true"
        resource = ""
      }
    ]
  }
}
