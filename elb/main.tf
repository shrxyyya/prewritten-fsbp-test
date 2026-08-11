terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-elb-logs-bucket-123456"
}

resource "aws_subnet" "example_a" {
  vpc_id            = "vpc-12345678"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "example_b" {
  vpc_id            = "vpc-12345678"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_lb" "example" {
  name                       = "example-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.example_a.id, aws_subnet.example_b.id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  desync_mitigation_mode     = "strictest"

  access_logs {
    bucket  = aws_s3_bucket.example.bucket
    enabled = true
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "vpc-12345678"

  health_check {
    protocol = "HTTPS"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/example"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_elb" "example" {
  name                        = "example-clb"
  subnets                     = [aws_subnet.example_a.id, aws_subnet.example_b.id]
  cross_zone_load_balancing   = true
  connection_draining         = true
  desync_mitigation_mode      = "strictest"
  security_groups             = []

  access_logs {
    bucket        = aws_s3_bucket.example.bucket
    enabled       = true
    interval      = 5
  }

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  }

  health_check {
    target              = "HTTPS:443/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}
