# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elbv2-multiple-az.policy.hcl"
  ]
}

inputs  {
  minAvailabilityZones = "3"
}

# Shared subnets (3 distinct AZs)
resource "aws_subnet" "az1" {
  attrs = {
    id                = "subnet-11111111"
    vpc_id            = "vpc-12345678"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
}

resource "aws_subnet" "az2" {
  attrs = {
    id                = "subnet-22222222"
    vpc_id            = "vpc-12345678"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
}

resource "aws_subnet" "az3" {
  attrs = {
    id                = "subnet-33333333"
    vpc_id            = "vpc-12345678"
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-east-1c"
  }
}

# Pass Case: NLB with targets in 3 AZs meets custom minimum of 3
resource "aws_lb" "nlb_compliant_min3" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-min3/123"
    name               = "my-nlb-min3"
    load_balancer_type = "network"
  }
}

resource "aws_lb_listener" "nlb_compliant_min3" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb-min3/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb-min3/123"
    }]
  }
}

resource "aws_instance" "nlb_min3_instance_a" {
  attrs = {
    id        = "i-nlb-az1"
    subnet_id = "subnet-11111111"
  }
}

resource "aws_instance" "nlb_min3_instance_b" {
  attrs = {
    id        = "i-nlb-az2"
    subnet_id = "subnet-22222222"
  }
}

resource "aws_instance" "nlb_min3_instance_c" {
  attrs = {
    id        = "i-nlb-az3"
    subnet_id = "subnet-33333333"
  }
}

resource "aws_lb_target_group_attachment" "nlb_min3_attachment_a" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb-min3/123"
    target_id        = "i-nlb-az1"
  }
}

resource "aws_lb_target_group_attachment" "nlb_min3_attachment_b" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb-min3/123"
    target_id        = "i-nlb-az2"
  }
}

resource "aws_lb_target_group_attachment" "nlb_min3_attachment_c" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb-min3/123"
    target_id        = "i-nlb-az3"
  }
}

# Fail Case: ALB with targets in only 2 AZs (below custom minimum of 3)
resource "aws_lb" "alb_non_compliant_min3" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-min3/123"
    name               = "my-alb-min3"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "alb_non_compliant_min3" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-min3/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-min3/123"
    }]
  }
}

resource "aws_instance" "alb_min3_instance_a" {
  attrs = {
    id        = "i-alb-az1"
    subnet_id = "subnet-11111111"
  }
}

resource "aws_instance" "alb_min3_instance_b" {
  attrs = {
    id        = "i-alb-az2"
    subnet_id = "subnet-22222222"
  }
}

resource "aws_lb_target_group_attachment" "alb_min3_attachment_a" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-min3/123"
    target_id        = "i-alb-az1"
  }
}

resource "aws_lb_target_group_attachment" "alb_min3_attachment_b" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-min3/123"
    target_id        = "i-alb-az2"
  }
}
