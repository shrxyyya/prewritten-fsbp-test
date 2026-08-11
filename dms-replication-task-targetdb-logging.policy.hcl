# Copyright IBM Corp. 2026

# DMS replication tasks for the target database should have logging enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "dms-replication-task-targetdb-logging-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_dms_replication_task" "logging_enabled" {
  enforcement_level = input.dms-replication-task-targetdb-logging-enforcement-level
  
  locals {
    # Parse the replication_task_settings JSON string
    # The settings are provided as an escaped JSON string
    settings_raw = core::try(attrs.replication_task_settings, "{}")
    
    # Parse JSON to get logging configuration
    # Note: In tfpolicy, we need to handle JSON parsing carefully
    # The replication_task_settings is a JSON string that needs to be decoded
    settings = core::try(core::jsondecode(local.settings_raw), {})
    
    # Extract Logging configuration
    logging = core::try(local.settings.Logging, {})
    
    # Check if logging is enabled
    enable_logging = core::try(local.logging.EnableLogging, false)
    
    # Get log components configuration
    log_components = core::try(local.logging.LogComponents, [])
    
    # Valid severity levels (in order of verbosity)
    valid_severities = [
      "LOGGER_SEVERITY_DEFAULT",
      "LOGGER_SEVERITY_DEBUG", 
      "LOGGER_SEVERITY_DETAILED_DEBUG"
    ]
    
    # Find TARGET_APPLY component
    target_apply_components = [
      for component in local.log_components :
      component if core::try(component.Id, "") == "TARGET_APPLY"
    ]
    
    # Find TARGET_LOAD component
    target_load_components = [
      for component in local.log_components :
      component if core::try(component.Id, "") == "TARGET_LOAD"
    ]
    
    # Check if TARGET_APPLY exists and has valid severity
    has_target_apply = core::length(local.target_apply_components) > 0
    target_apply_severity = local.has_target_apply ? core::try(local.target_apply_components[0].Severity, "") : ""
    target_apply_valid = local.has_target_apply && core::contains(local.valid_severities, local.target_apply_severity)
    target_apply_display = local.has_target_apply ? local.target_apply_severity : "not configured"
    
    # Check if TARGET_LOAD exists and has valid severity
    has_target_load = core::length(local.target_load_components) > 0
    target_load_severity = local.has_target_load ? core::try(local.target_load_components[0].Severity, "") : ""
    target_load_valid = local.has_target_load && core::contains(local.valid_severities, local.target_load_severity)
    target_load_display = local.has_target_load ? local.target_load_severity : "not configured"
  }
  
  # Enforce: Logging must be enabled
  enforce {
    condition = local.enable_logging == true
    error_message = "DMS replication task must have logging enabled. Set 'EnableLogging' to true in replication_task_settings.Logging configuration"
  }
  
  # Enforce: TARGET_APPLY component must exist with valid severity
  enforce {
    condition = local.target_apply_valid
    error_message = "DMS replication task must have TARGET_APPLY logging component configured with severity level of LOGGER_SEVERITY_DEFAULT, LOGGER_SEVERITY_DEBUG, or LOGGER_SEVERITY_DETAILED_DEBUG. Current: ${local.target_apply_display}"
  }
  
  # Enforce: TARGET_LOAD component must exist with valid severity
  enforce {
    condition = local.target_load_valid
    error_message = "DMS replication task must have TARGET_LOAD logging component configured with severity level of LOGGER_SEVERITY_DEFAULT, LOGGER_SEVERITY_DEBUG, or LOGGER_SEVERITY_DETAILED_DEBUG. Current: ${local.target_load_display}"
  }
}
