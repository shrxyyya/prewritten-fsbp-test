# Copyright IBM Corp. 2026

# Amazon EC2 Auto Scaling groups should use Amazon EC2 launch templates
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "autoscaling-launch-template-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_autoscaling_group" "use_launch_templates" {
    enforcement_level = input.autoscaling-launch-template-enforcement-level
    locals {
        # Check if launch_template is configured
        has_launch_template = core::try(attrs.launch_template, null) != null
        
        # Check if mixed_instances_policy with launch_template is configured
        has_mixed_instances_policy = core::try(attrs.mixed_instances_policy, null) != null
        mixed_policy_has_template = local.has_mixed_instances_policy && core::try(attrs.mixed_instances_policy[0].launch_template, null) != null
        
        # Check if only launch_configuration is used (deprecated approach)
        has_launch_configuration = core::try(attrs.launch_configuration, null) != null
        
        # Compliance: Must have launch_template OR mixed_instances_policy.launch_template
        uses_launch_template = local.has_launch_template || local.mixed_policy_has_template
        
        # Violation: Uses only launch_configuration without launch_template
        uses_only_launch_config = local.has_launch_configuration && !local.uses_launch_template
    }

    enforce {
        condition = local.uses_launch_template
        error_message = "Auto Scaling Group must use a launch template. Either configure 'launch_template' or 'mixed_instances_policy.launch_template'. Launch configurations are deprecated and do not provide access to the latest features"
    }

    enforce {
        condition = !local.uses_only_launch_config
        error_message = "Auto Scaling Group uses only 'launch_configuration' which is deprecated. Replace it with a launch template by configuring 'launch_template' or 'mixed_instances_policy.launch_template'"
    }
}
