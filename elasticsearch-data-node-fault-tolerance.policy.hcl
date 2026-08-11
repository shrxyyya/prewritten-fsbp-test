# Copyright IBM Corp. 2026

# Elasticsearch domains should have at least three data nodes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-data-node-fault-tolerance-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticsearch_domain" "three_data_nodes" {
    enforcement_level = input.elasticsearch-data-node-fault-tolerance-enforcement-level
    filter = core::try(attrs.cluster_config, null) != null || core::length(core::try(attrs.cluster_config, [])) > 0

    locals {
        cluster_config = core::try(attrs.cluster_config[0], {})
        instance_count = core::try(local.cluster_config.instance_count, 1)

        zone_awareness_enabled = core::try(local.cluster_config.zone_awareness_enabled, false)
        has_minimum_nodes = local.instance_count >= 3
    }

    enforce {
        condition = local.has_minimum_nodes
        error_message = "Elasticsearch domain must have at least 3 data nodes for high availability. Set cluster_config.instance_count to 3 or more"
    }

    # Enforce zone awareness is enabled
    enforce {
        condition = local.zone_awareness_enabled
        error_message = "Elasticsearch domain must have zone_awareness_enabled set to true for fault tolerance. Set cluster_config.zone_awareness_enabled = true"
    }
}
