# Copyright IBM Corp. 2026

# AWS Config should be enabled and use the service-linked role for resource recording

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "config1-aws-config-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "includeConfigServiceLinkedRoleCheck" {
  type    = bool
  default = true
}

# Validate Configuration Recorder configuration
resource_policy "aws_config_configuration_recorder" "recorder_configuration" {
  enforcement_level = input.config1-aws-config-enabled-enforcement-level
  locals {
    recording_group     = core::try(attrs.recording_group, {})
    has_recording_group = core::length(core::keys(local.recording_group)) > 0
    all_supported       = core::try(local.recording_group.all_supported, false)
    include_global      = core::try(local.recording_group.include_global_resource_types, false)

    role_arn                 = core::try(attrs.role_arn, "")
    uses_service_linked_role = core::try(core::length(core::regexall("/aws-service-role/config\\.amazonaws\\.com/AWSServiceRoleForConfig$", local.role_arn)), 0) > 0

    records_everything = local.has_recording_group && local.all_supported && local.include_global
  }

  enforce {
    condition     = local.records_everything
    error_message = "Configuration recorder must declare a recording_group with all_supported=true and include_global_resource_types=true so AWS Config records every supported resource type, including IAM global resources"
  }

  enforce {
    condition     = !input.includeConfigServiceLinkedRoleCheck || local.uses_service_linked_role
    error_message = "Configuration recorder must use the AWS Config service-linked role (role_arn must match '/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig'). Set input.includeConfigServiceLinkedRoleCheck=false to skip this check"
  }
}

# Validate Configuration Recorder Status is enabled
resource_policy "aws_config_configuration_recorder_status" "recorder_enabled" {
  enforcement_level = input.config1-aws-config-enabled-enforcement-level
  enforce {
    condition     = core::try(attrs.is_enabled, false) == true
    error_message = "AWS Config configuration recorder must be enabled (is_enabled=true)"
  }
}

# Validate Delivery Channel has S3 bucket configured
resource_policy "aws_config_delivery_channel" "delivery_channel_configuration" {
  enforcement_level = input.config1-aws-config-enabled-enforcement-level
  enforce {
    condition     = core::try(attrs.s3_bucket_name, "") != ""
    error_message = "AWS Config delivery channel must have a non-empty s3_bucket_name configured"
  }
}
