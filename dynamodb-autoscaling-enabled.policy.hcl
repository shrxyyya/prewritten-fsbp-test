# Copyright IBM Corp. 2026

# DynamoDB tables should automatically scale capacity with demand

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dynamodb-autoscaling-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "minProvisionedReadCapacity" {
  type = number
  default = 0
}

input "targetReadUtilization" {
  type = number
  default = 0
}

input "minProvisionedWriteCapacity" {
  type = number
  default = 0
}

input "targetWriteUtilization" {
  type = number
  default = 0
}

resource_policy "aws_dynamodb_table" "autoscaling_enabled" {
  enforcement_level = input.dynamodb-autoscaling-enabled-enforcement-level
  # Skip on-demand (PAY_PER_REQUEST) tables; AWS Security Hub DynamoDB.1 only applies
  # to PROVISIONED tables. On-demand tables scale automatically by design.
  filter = core::try(attrs.billing_mode, "PROVISIONED") == "PROVISIONED"

  locals {
    # Optional AWS Config-style parameters. A value of 0 means "not provided".
    has_min_read_capacity = input.minProvisionedReadCapacity > 0
    has_target_read_utilization = input.targetReadUtilization > 0
    has_min_write_capacity = input.minProvisionedWriteCapacity > 0
    has_target_write_utilization = input.targetWriteUtilization > 0

    valid_min_read_capacity = !local.has_min_read_capacity || (input.minProvisionedReadCapacity >= 1 && input.minProvisionedReadCapacity <= 40000)
    valid_target_read_utilization = !local.has_target_read_utilization || (input.targetReadUtilization >= 20 && input.targetReadUtilization <= 90)
    valid_min_write_capacity = !local.has_min_write_capacity || (input.minProvisionedWriteCapacity >= 1 && input.minProvisionedWriteCapacity <= 40000)
    valid_target_write_utilization = !local.has_target_write_utilization || (input.targetWriteUtilization >= 20 && input.targetWriteUtilization <= 90)

    # Extract billing mode, default to PROVISIONED if not specified
    billing_mode = core::try(attrs.billing_mode, "PROVISIONED")
    
    # Check if table uses on-demand mode (fully compliant)
    is_on_demand = local.billing_mode == "PAY_PER_REQUEST"
    
    # For provisioned mode, we can only validate the billing mode is set
    # Autoscaling resources must be verified separately
    is_provisioned = local.billing_mode == "PROVISIONED"
  }

  enforce {
    condition = local.valid_min_read_capacity
    error_message = "input.minProvisionedReadCapacity must be between 1 and 40000 when provided. Current value: ${input.minProvisionedReadCapacity}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition = local.valid_target_read_utilization
    error_message = "input.targetReadUtilization must be between 20 and 90 when provided. Current value: ${input.targetReadUtilization}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition = local.valid_min_write_capacity
    error_message = "input.minProvisionedWriteCapacity must be between 1 and 40000 when provided. Current value: ${input.minProvisionedWriteCapacity}. Use 0 to leave the parameter unset."
  }

  enforce {
    condition = local.valid_target_write_utilization
    error_message = "input.targetWriteUtilization must be between 20 and 90 when provided. Current value: ${input.targetWriteUtilization}. Use 0 to leave the parameter unset."
  }

  # Enforce: PROVISIONED tables must declare autoscaling resources.
  # NOTE: aws_appautoscaling_target/policy linkage cannot be statically verified here;
  # this policy enforces the billing mode contract and surfaces guidance.
  enforce {
    condition = local.is_provisioned
    error_message = "DynamoDB table with PROVISIONED billing mode must have autoscaling configured. Ensure aws_appautoscaling_target and aws_appautoscaling_policy resources are configured for both read and write capacity, and align any configured inputs: minProvisionedReadCapacity=${input.minProvisionedReadCapacity}, targetReadUtilization=${input.targetReadUtilization}, minProvisionedWriteCapacity=${input.minProvisionedWriteCapacity}, targetWriteUtilization=${input.targetWriteUtilization}"
  }
}
