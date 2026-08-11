# Copyright IBM Corp. 2026

# VPC flow logging should be enabled in all VPCs

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "vpc-flow-logs-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

locals {
  all_flow_logs = core::getresources("aws_flow_log", {})

  required_traffic_type = "REJECT"
}

resource_policy "aws_vpc" "flow_logging_enabled" {
  enforcement_level = input.vpc-flow-logs-enabled-enforcement-level
  locals {
    vpc_id = core::try(attrs.id, "")
    has_known_vpc_id = core::try(attrs.id != "", false)
    # Find flow logs associated with this VPC
    vpc_flow_logs = [
      for log in local.all_flow_logs :
      log if core::try(log.vpc_id == local.vpc_id, false)
    ]
    
    # Check if any flow log exists for this VPC
    has_flow_log = local.has_known_vpc_id && core::try(core::length(local.vpc_flow_logs) > 0, false)

    # Check if any flow log has traffic_type set to the required non-customizable value
    reject_logs = [
      for log in local.vpc_flow_logs :
      log if core::try(log.traffic_type, "") == local.required_traffic_type
    ]
    
    has_reject_logging = local.has_known_vpc_id && core::try(core::length(local.reject_logs) > 0, false)
  }

  enforce {
    condition     = !local.has_known_vpc_id || local.has_flow_log
    error_message = "VPC must have VPC Flow Logs enabled. Create an aws_flow_log resource with vpc_id = ${attrs.id}"
  }

  enforce {
    condition     = !local.has_known_vpc_id || local.has_reject_logging
    error_message = "VPC must have VPC Flow Logs with traffic_type set to '${local.required_traffic_type}'. Current flow logs do not capture the required rejected traffic"
  }
}
