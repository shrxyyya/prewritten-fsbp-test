# Copyright IBM Corp. 2026

# CloudFormation stacks should have associated service roles

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "cloudformation-stack-service-role-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_cloudformation_stack" "service_role_required" {
    enforcement_level = input.cloudformation-stack-service-role-check-enforcement-level
    locals {
        # Safely extract the iam_role_arn attribute
        iam_role_arn = core::try(attrs.iam_role_arn, null)
        
        # Check if service role is configured
        has_service_role = local.iam_role_arn != null && local.iam_role_arn != ""
    }

    enforce {
        condition     = local.has_service_role
        error_message = "CloudFormation stack must have a service role associated. Set the 'iam_role_arn' attribute to an IAM role ARN that AWS CloudFormation can assume to create the stack"
    }
}
