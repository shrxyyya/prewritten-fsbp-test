# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elbv2-multiple-az.policy.hcl"
  ]
}

# Shared subnets
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

# Pass Case 1: ALB with targets in 2 AZs using the default minimum of 2
resource "aws_lb" "alb_compliant" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/123"
    name               = "my-alb"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "alb_compliant" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb/123"
    }]
  }
}

resource "aws_instance" "alb_instance_a" {
  attrs = {
    id        = "i-alb-az1"
    subnet_id = "subnet-11111111"
  }
}

resource "aws_instance" "alb_instance_b" {
  attrs = {
    id        = "i-alb-az2"
    subnet_id = "subnet-22222222"
  }
}

resource "aws_lb_target_group_attachment" "alb_attachment_a" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb/123"
    target_id        = "i-alb-az1"
  }
}

resource "aws_lb_target_group_attachment" "alb_attachment_b" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb/123"
    target_id        = "i-alb-az2"
  }
}

# Pass Case 2: NLB with targets in 3 AZs and minAvailabilityZones set to 3
resource "aws_lb" "nlb_compliant" {
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/123"
    name               = "my-nlb"
    load_balancer_type = "network"
  }
}

resource "aws_lb_listener" "nlb_compliant" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/my-nlb/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb/123"
    }]
  }
}

resource "aws_instance" "nlb_instance_a" {
  attrs = {
    id        = "i-nlb-az1"
    subnet_id = "subnet-11111111"
  }
}

resource "aws_instance" "nlb_instance_b" {
  attrs = {
    id        = "i-nlb-az2"
    subnet_id = "subnet-22222222"
  }
}

resource "aws_instance" "nlb_instance_c" {
  attrs = {
    id        = "i-nlb-az3"
    subnet_id = "subnet-33333333"
  }
}

resource "aws_lb_target_group_attachment" "nlb_attachment_a" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb/123"
    target_id        = "i-nlb-az1"
  }
}

resource "aws_lb_target_group_attachment" "nlb_attachment_b" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb/123"
    target_id        = "i-nlb-az2"
  }
}

resource "aws_lb_target_group_attachment" "nlb_attachment_c" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/nlb/123"
    target_id        = "i-nlb-az3"
  }
}

# Fail Case 1: ALB with registered instances in only 1 AZ
resource "aws_lb" "alb_non_compliant" {
  expect_failure = true
  attrs = {
    arn                = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-single-az/123"
    name               = "my-alb-single-az"
    load_balancer_type = "application"
  }
}

resource "aws_lb_listener" "alb_non_compliant" {
  attrs = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb-single-az/123"
    default_action = [{
      type             = "forward"
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-single/123"
    }]
  }
}

resource "aws_instance" "alb_single_instance" {
  attrs = {
    id        = "i-alb-single"
    subnet_id = "subnet-11111111"
  }
}

resource "aws_lb_target_group_attachment" "alb_single_attachment" {
  attrs = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/alb-single/123"
    target_id        = "i-alb-single"
  }
}
