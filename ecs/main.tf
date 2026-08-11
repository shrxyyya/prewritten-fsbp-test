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

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/ecs/example"
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "example" {
  name = "example-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = "arn:aws:autoscaling:us-east-1:123456789012:autoScalingGroup:*:autoScalingGroupName/example"

    managed_termination_protection = "ENABLED"
  }
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name                   = "app"
      image                  = "nginx:latest"
      essential              = true
      readonlyRootFilesystem = true
      privileged             = false
      user                   = "1000"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.example.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      linuxParameters = {
        initProcessEnabled = true
      }
      mountPoints = []
      environment = []
      secrets     = []
    }
  ])

  volume {
    name = "shared-storage"

    efs_volume_configuration {
      file_system_id     = "fs-12345678"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_subnet" "example" {
  vpc_id                  = "vpc-12345678"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_security_group" "example" {
  name   = "example-ecs-sg"
  vpc_id = "vpc-12345678"
}

resource "aws_ecs_service" "example" {
  name             = "example-service"
  cluster          = aws_ecs_cluster.example.id
  task_definition  = aws_ecs_task_definition.example.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = [aws_subnet.example.id]
    security_groups  = [aws_security_group.example.id]
    assign_public_ip = false
  }
}

resource "aws_ecs_task_set" "example" {
  service         = aws_ecs_service.example.id
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn

  network_configuration {
    subnets          = [aws_subnet.example.id]
    security_groups  = [aws_security_group.example.id]
    assign_public_ip = false
  }
}
