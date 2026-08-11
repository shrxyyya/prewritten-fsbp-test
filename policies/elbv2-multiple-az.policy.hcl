# Copyright IBM Corp. 2026

# Application, Network and Gateway Load Balancers should span multiple Availability Zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elbv2-multiple-az-enforcement-level" {
  type = string
  default = "advisory"
}

input "minAvailabilityZones" {
    type = string
    default = "2"
}

locals {
    all_listeners = core::getresources("aws_lb_listener", {})
    all_target_group_attachments = core::getresources("aws_lb_target_group_attachment", {})
    all_instances = core::getresources("aws_instance", {})
    elb_all_subnets = core::getresources("aws_subnet", {})
}

resource_policy "aws_lb" "multiple_az_required" {
    enforcement_level = input.elbv2-multiple-az-enforcement-level
    locals {
        allowed_min_az_values = ["2", "3", "4", "5", "6"]
        has_valid_min_az_input = core::contains(local.allowed_min_az_values, input.minAvailabilityZones)

        lb_name = core::try(attrs.name, "Load Balancer")
        lb_type = core::try(attrs.load_balancer_type, "application")
        lb_arn = core::try(attrs.arn, "")

        matching_listeners = [
            for listener in local.all_listeners :
            listener if core::try(listener.load_balancer_arn, "") == local.lb_arn
        ]

        listener_target_group_arns = [
            for action in core::flatten([
                for listener in local.matching_listeners :
                core::try(listener.default_action, [])
            ]) :
            core::try(action.target_group_arn, "") if core::try(action.target_group_arn, "") != ""
        ]

        matching_attachments = [
            for attachment in local.all_target_group_attachments :
            attachment if core::contains(local.listener_target_group_arns, core::try(attachment.target_group_arn, ""))
        ]

        matching_instances = [
            for instance in local.all_instances :
            instance if core::contains([
                for attachment in local.matching_attachments :
                core::try(attachment.target_id, "")
            ], core::try(instance.id, ""))
        ]

        target_subnet_ids = [
            for instance in local.matching_instances :
            core::try(instance.subnet_id, "") if core::try(instance.subnet_id, "") != ""
        ]

        target_availability_zones = [
            for subnet in local.elb_all_subnets :
            core::try(subnet.availability_zone, "") if core::contains(local.target_subnet_ids, core::try(subnet.id, "")) && core::try(subnet.availability_zone, "") != ""
        ]

        unique_target_azs = {
            for availability_zone in local.target_availability_zones :
            availability_zone => true
        }

        unique_target_az_count = core::length(core::keys(local.unique_target_azs))

        target_instance_ids = [
            for instance in local.matching_instances :
            core::try(instance.id, "") if core::try(instance.id, "") != ""
        ]

        target_az_details = [
            for subnet in local.elb_all_subnets :
            "${subnet.id} (${subnet.availability_zone})" if core::contains(local.target_subnet_ids, core::try(subnet.id, ""))
        ]

        min_az_map = {
            "2" = 2
            "3" = 3
            "4" = 4
            "5" = 5
            "6" = 6
        }
        min_az_required = core::try(local.min_az_map[input.minAvailabilityZones], 2)
        meets_minimum   = local.unique_target_az_count >= local.min_az_required
    }

    enforce {
        condition = local.has_valid_min_az_input
        error_message = "input.minAvailabilityZones must be one of 2, 3, 4, 5, or 6. Current value: '${input.minAvailabilityZones}'. The AWS Security Hub default is '2'."
    }

    enforce {
        condition = local.meets_minimum
        error_message = "Load Balancer has registered targets in fewer Availability Zones than required by input.minAvailabilityZones"
    }
}
