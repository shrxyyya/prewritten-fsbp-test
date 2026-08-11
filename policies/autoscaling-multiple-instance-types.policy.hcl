# Copyright IBM Corp. 2026

# Auto Scaling groups should use multiple instance types in multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "autoscaling-multiple-instance-types-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_autoscaling_group" "multiple_instance_types_and_azs" {
  enforcement_level = input.autoscaling-multiple-instance-types-enforcement-level
  
  locals {
    # Check if mixed_instances_policy exists
    has_mixed_instances_policy = core::try(attrs.mixed_instances_policy, null) != null
    
    # Extract instance type overrides from mixed_instances_policy
    instance_overrides = core::try(
      attrs.mixed_instances_policy[0].launch_template[0].override,
      []
    )
    
    # Count unique instance types in overrides
    instance_types = [
      for override in local.instance_overrides :
      core::try(override.instance_type, "")
      if core::try(override.instance_type, "") != ""
    ]
    instance_type_count = core::length(local.instance_types)
    
    # Check Availability Zones configuration
    # Option 1: vpc_zone_identifier (list of subnet IDs)
    vpc_zone_subnets = core::try(attrs.vpc_zone_identifier, [])
    vpc_zone_count = core::length(local.vpc_zone_subnets)
    
    # Option 2: availability_zones (list of AZ names)
    availability_zones = core::try(attrs.availability_zones, [])
    az_count = core::length(local.availability_zones)
    
    # Determine if multiple AZs are configured
    has_multiple_azs = local.vpc_zone_count >= 2 || local.az_count >= 2
    
    # Check for legacy launch_configuration (not compatible with multiple instance types)
    uses_launch_configuration = core::try(attrs.launch_configuration, null) != null
  }
  
  # Enforce: Must use mixed_instances_policy (not legacy launch_configuration)
  enforce {
    condition = !local.uses_launch_configuration
    error_message = "Auto Scaling group uses legacy launch_configuration which does not support multiple instance types. Use mixed_instances_policy with launch_template instead"
  }
  
  # Enforce: Must have mixed_instances_policy configured
  enforce {
    condition = local.has_mixed_instances_policy
    error_message = "Auto Scaling group must use mixed_instances_policy to support multiple instance types for high availability"
  }
  
  # Enforce: Must have at least 2 instance type overrides
  enforce {
    condition = local.instance_type_count >= 2
    error_message = "Auto Scaling group must define at least 2 different instance types in mixed_instances_policy.launch_template.override. Currently has ${local.instance_type_count} instance type(s). This ensures the Auto Scaling group can launch alternative instance types if capacity is insufficient"
  }
  
  # Enforce: Must span multiple Availability Zones
  enforce {
    condition = local.has_multiple_azs
    error_message = "Auto Scaling group must span at least 2 Availability Zones. Configure either vpc_zone_identifier with subnets in multiple AZs (currently ${local.vpc_zone_count} subnet(s)) or availability_zones with multiple AZ names (currently ${local.az_count} AZ(s))"
  }
}
