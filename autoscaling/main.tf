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

resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  metadata_options {
    # autoscaling-launchconfig-requires-imdsv2: enforce IMDSv2
    http_tokens = "required"
  }
}

resource "aws_launch_configuration" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # autoscaling-launch-config-public-ip-disabled: no public IP
  associate_public_ip_address = false

  metadata_options {
    # autoscaling-launchconfig-requires-imdsv2: enforce IMDSv2
    http_tokens = "required"
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-00000000"
}

resource "aws_autoscaling_group" "example" {
  name               = "example-asg"
  min_size           = 1
  max_size           = 6
  desired_capacity   = 2
  health_check_type  = "ELB"

  # autoscaling-group-elb-healthcheck-required: target group association
  target_group_arns = [aws_lb_target_group.example.arn]

  # autoscaling-launch-template & autoscaling-multiple-instance-types: mixed instances policy
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example.id
        version            = "$Latest"
      }

      # autoscaling-multiple-instance-types: at least 2 instance type overrides
      override {
        instance_type = "t3.micro"
      }
      override {
        instance_type = "t3.small"
      }
    }
  }

  # autoscaling-multiple-instance-types: multiple availability zones
  vpc_zone_identifier = ["subnet-00000001", "subnet-00000002"]
}
