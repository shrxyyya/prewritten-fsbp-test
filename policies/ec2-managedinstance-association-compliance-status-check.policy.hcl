# Copyright IBM Corp. 2026

# Amazon EC2 instances managed by Systems Manager should have an association compliance status of COMPLIANT

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.0, < 7.0.0"
    }
  }
}

input "ec2-managedinstance-association-compliance-status-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_ssm_association" "association_compliance_check" {
    enforcement_level = input.ec2-managedinstance-association-compliance-status-check-enforcement-level
    locals {

        # Check if document name is specified (required)
        has_document = core::try(attrs.name, "") != ""
        
        # Check if targets are defined (required for association to work)
        targets_value = core::try(attrs.targets, [])
        has_targets = core::length(local.targets_value) > 0
        
        # Check if compliance severity is set (recommended for better compliance tracking)
        has_compliance_severity = core::try(attrs.compliance_severity, "") != ""
        
        # Valid compliance severity values
        valid_severities = ["UNSPECIFIED", "LOW", "MEDIUM", "HIGH", "CRITICAL"]
        compliance_severity_value_raw = core::try(attrs.compliance_severity, null)
        compliance_severity_value = local.compliance_severity_value_raw != null ? local.compliance_severity_value_raw : "UNSPECIFIED"
        is_valid_severity = core::contains(local.valid_severities, local.compliance_severity_value)
        
        # Check if sync_compliance is configured (recommended for automatic compliance updates)
        sync_compliance_value_raw = core::try(attrs.sync_compliance, null)
        sync_compliance_value = local.sync_compliance_value_raw != null ? local.sync_compliance_value_raw : ""
        has_sync_compliance = local.sync_compliance_value != ""
        is_auto_sync = local.sync_compliance_value == "AUTO"
    }

    # Enforce: Association must have a valid SSM document name
    enforce {
        condition = local.has_document
        error_message = "SSM Association must specify a valid SSM document name. The 'name' attribute is required for the association to execute and achieve COMPLIANT status"
    }

    # Enforce: Association must have targets defined
    enforce {
        condition = local.has_targets
        error_message = "SSM Association must have targets defined. Without targets, the association cannot run on any instances and will not have a compliance status. Define targets using instance IDs or tags"
    }

    # Enforce: If compliance_severity is set, it must be a valid value
    enforce {
        condition = !local.has_compliance_severity || local.is_valid_severity
        error_message = "SSM Association has invalid compliance_severity '${local.compliance_severity_value}'. Valid values are: ${core::join(", ", local.valid_severities)}. Proper severity classification helps with compliance tracking and reporting"
    }

    # Advisory: Recommend setting compliance_severity for better tracking
    enforce {
        condition = local.has_compliance_severity
        error_message = "SSM Association should specify a compliance_severity (LOW, MEDIUM, HIGH, or CRITICAL) for better compliance tracking and alignment with AWS Security Hub severity levels. This control has severity: Low"
    }

    # Advisory: Recommend AUTO sync_compliance for automatic status updates
    enforce {
        condition = local.has_sync_compliance && local.is_auto_sync
        error_message = "SSM Association should set sync_compliance to 'AUTO' for automatic compliance status updates. This ensures the compliance status is kept current after each association execution, which is essential for meeting the SSM.3 control requirement"
    }
}

# Policy for EC2 instances to ensure they can be managed by Systems Manager
# This is a prerequisite for association compliance - instances must be SSM-managed
resource_policy "aws_instance" "ssm_managed_prerequisite" {
    enforcement_level = input.ec2-managedinstance-association-compliance-status-check-enforcement-level
    locals {
        # Check if instance has IAM instance profile (required for SSM management)
        has_iam_profile = core::try(attrs.iam_instance_profile != "", false)

        # Check if user_data might install SSM agent (heuristic check)
        user_data = core::try(attrs.user_data, "")
        user_data_base64 = core::try(attrs.user_data_base64, "")
        has_user_data = local.user_data != "" || local.user_data_base64 != ""
    }

    # Enforce: Instance must have IAM instance profile for SSM management
    enforce {
        condition = local.has_iam_profile
        error_message = "EC2 Instance must have an IAM instance profile attached to be managed by AWS Systems Manager. Without proper IAM permissions, the instance cannot be managed by Systems Manager and cannot have association compliance status. Attach an instance profile with the AmazonSSMManagedInstanceCore policy or equivalent permissions"
    }

    # Advisory: Recommend user_data for SSM agent installation
    enforce {
        condition = local.has_user_data
        error_message = "EC2 Instance should include user_data to ensure SSM agent is installed and running. While some AMIs include the SSM agent by default, explicitly installing it in user_data ensures the instance can be managed by Systems Manager. This is a prerequisite for association compliance status"
    }
}
