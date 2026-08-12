# Copyright IBM Corp. 2026

policytest {
  targets = ["autoscaling-group-elb-healthcheck-required.policy.hcl"]
}

# PASS: ASG with health_check_type="ELB" and a matching classic ELB attachment
resource "aws_autoscaling_group" "pass_elb_healthcheck_with_elb_attachment" {
  attrs = {
    name              = "asg-elb-compliant"
    max_size          = 3
    min_size          = 1
    health_check_type = "ELB"
  }
}

resource "aws_autoscaling_attachment" "pass_elb_attachment" {
  skip = true
  attrs = {
    autoscaling_group_name = "asg-elb-compliant"
    elb                    = "my-classic-elb"
  }
}

# FAIL: ASG with health_check_type="EC2" despite having a classic ELB attachment
resource "aws_autoscaling_group" "fail_ec2_healthcheck_with_elb_attachment" {
  expect_failure = true
  attrs = {
    name              = "asg-ec2-noncompliant"
    max_size          = 3
    min_size          = 1
    health_check_type = "EC2"
  }
}

resource "aws_autoscaling_attachment" "fail_ec2_attachment" {
  skip = true
  attrs = {
    autoscaling_group_name = "asg-ec2-noncompliant"
    elb                    = "my-classic-elb-2"
  }
}

# FAIL: ASG with health_check_type="ELB" but the attachment uses only lb_target_group_arn (ALB/NLB)
resource "aws_autoscaling_group" "fail_elb_healthcheck_no_classic_elb" {
  expect_failure = true
  attrs = {
    name              = "asg-alb-only"
    max_size          = 2
    min_size          = 1
    health_check_type = "ELB"
  }
}

resource "aws_autoscaling_attachment" "fail_alb_only_attachment" {
  skip = true
  attrs = {
    autoscaling_group_name = "asg-alb-only"
    lb_target_group_arn    = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/abc123"
  }
}

# FAIL: ASG with health_check_type="ELB" but the ELB attachment references a different ASG name
resource "aws_autoscaling_group" "fail_elb_healthcheck_wrong_attachment_name" {
  expect_failure = true
  attrs = {
    name              = "asg-mismatched"
    max_size          = 2
    min_size          = 1
    health_check_type = "ELB"
  }
}

resource "aws_autoscaling_attachment" "fail_mismatched_attachment" {
  skip = true
  attrs = {
    autoscaling_group_name = "other-asg"
    elb                    = "my-classic-elb-3"
  }
}

# FAIL: ASG with health_check_type missing and a classic ELB attachment
resource "aws_autoscaling_group" "fail_missing_healthcheck_type" {
  expect_failure = true
  attrs = {
    name     = "asg-no-healthcheck"
    max_size = 2
    min_size = 1
  }
}

resource "aws_autoscaling_attachment" "fail_missing_healthcheck_attachment" {
  skip = true
  attrs = {
    autoscaling_group_name = "asg-no-healthcheck"
    elb                    = "my-classic-elb-4"
  }
}
