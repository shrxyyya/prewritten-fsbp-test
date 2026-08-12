# Copyright IBM Corp. 2026

# DMS endpoints for MongoDB should have an authentication mechanism enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-mongo-db-authentication-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dms_endpoint" "dms_mongo_db_authentication_enabled" {
  # Only evaluate MongoDB endpoints
  filter = core::try(attrs.engine_name, "") == "mongodb"

  locals {
    # Safely access mongodb_settings block (it's a list of maps in provider schema)
    mongodb_settings_list = core::try(attrs.mongodb_settings, [])
    has_mongodb_settings = core::length(local.mongodb_settings_list) > 0

    # Get the first (and only) mongodb_settings block
    mongodb_settings = local.has_mongodb_settings ? local.mongodb_settings_list[0] : {}

    # Get auth_mechanism value, defaulting to "default" if not set (matching Sentinel behavior)
    auth_mechanism = core::try(local.mongodb_settings.auth_mechanism, "default")

    # Policy is violated if auth_mechanism is "default"
    is_compliant = local.auth_mechanism != "default"
  }

  enforcement_level = input.dms-mongo-db-authentication-enabled-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'auth_mechanism' shouldn't be 'default' in 'mongodb_settings' for engine of type 'mongodb' in AWS DMS Endpoint"
  }
}