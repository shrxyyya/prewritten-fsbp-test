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

resource "aws_dax_cluster" "example" {
  cluster_name       = "example-dax-cluster"
  iam_role_arn       = "arn:aws:iam::123456789012:role/dax-role"
  node_type          = "dax.r4.large"
  replication_factor = 1

  # dax-encryption-enabled: SSE at rest must be enabled
  server_side_encryption {
    enabled = true
  }

  # dax-tls-endpoint-encryption: in-transit encryption must be TLS
  cluster_endpoint_encryption_type = "TLS"
}

resource "aws_dynamodb_table" "example" {
  name         = "example-table"
  billing_mode = "PROVISIONED"
  hash_key     = "id"

  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "id"
    type = "S"
  }

  # dynamodb-pitr-enabled: point-in-time recovery must be enabled
  point_in_time_recovery {
    enabled = true
  }

  # dynamodb-table-deletion-protection-enabled: deletion protection required
  deletion_protection_enabled = true
}

# dynamodb-autoscaling-enabled: autoscaling targets and policies for PROVISIONED table
resource "aws_appautoscaling_target" "read" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.example.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  name               = "example-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read.resource_id
  scalable_dimension = aws_appautoscaling_target.read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "write" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.example.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  name               = "example-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write.resource_id
  scalable_dimension = aws_appautoscaling_target.write.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}
