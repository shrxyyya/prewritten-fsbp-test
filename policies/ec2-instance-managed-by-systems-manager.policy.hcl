# Copyright IBM Corp. 2026

# Amazon EC2 instances should be managed by AWS Systems Manager

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "ec2-instance-managed-by-systems-manager-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_instance" "ssm_managed_instance" {
  enforcement_level = input.ec2-instance-managed-by-systems-manager-enforcement-level
  locals {
    # Safe access to IAM instance profile
    instance_profile_name = core::try(attrs.iam_instance_profile, "")
    has_instance_profile = local.instance_profile_name != ""
    
    # Check for AWS Elastic Disaster Recovery tags (these should be excluded)
    instance_tags_raw = core::try(attrs.tags, null)
    instance_tags = local.instance_tags_raw != null ? local.instance_tags_raw : {}
    is_disaster_recovery = core::contains(
      core::keys(local.instance_tags),
      "AWSElasticDisasterRecoveryManaged"
    ) || core::contains(
      core::keys(local.instance_tags),
      "aws:elasticdr:replication-server"
    )
  }
  
  # Enforce: Instance must have IAM instance profile (unless it's a disaster recovery instance)
  enforce {
    condition = local.has_instance_profile || local.is_disaster_recovery
    error_message = "EC2 instance must have an IAM instance profile attached to be managed by AWS Systems Manager. The instance profile should have a role with the AmazonSSMManagedInstanceCore managed policy attached"
  }
}
