# Copyright IBM Corp. 2026

# autoscaling-group-elb-healthcheck-required

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "autoscaling-group-elb-healthcheck-required-enforcement-level" {
  type    = string
  default = "advisory"
}

locals {
  all_attachments = core::getresources("aws_autoscaling_attachment", {})

  elb_attachments = [for att in local.all_attachments : att if core::try(att.elb, null) != null && core::try(att.elb, "") != ""]

  elb_attached_asg_names = [for att in local.elb_attachments : core::try(att.autoscaling_group_name, "")]

  has_any_attachment = core::length(local.all_attachments) > 0
}

resource_policy "aws_autoscaling_group" "elb_healthcheck_required" {
  enforcement_level = input.autoscaling-group-elb-healthcheck-required-enforcement-level
  filter = local.has_any_attachment

  locals {
    asg_name          = core::try(attrs.name, "")
    health_check_type = core::try(attrs.health_check_type, "")

    is_elb_attached = core::length([for n in local.elb_attached_asg_names : n if n == local.asg_name]) > 0

    is_compliant = local.health_check_type == "ELB" && local.is_elb_attached
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'health_check_type' must be 'ELB' for 'aws_autoscaling_group' and should be associated with the load balancer resource."
  }
}
