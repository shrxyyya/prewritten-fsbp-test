# Copyright IBM Corp. 2026

# Elasticsearch domains should encrypt data sent between nodes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-node-to-node-encryption-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticsearch_domain" "node_to_node_encryption" {
    enforcement_level = input.elasticsearch-node-to-node-encryption-check-enforcement-level
    locals {
        node_to_node_encryption = core::try(attrs.node_to_node_encryption, null)
        es_version = core::try(attrs.elasticsearch_version, "1.5")
        valid_version = core::semverconstraint(local.es_version, ">= 6.0.0")
    }
    
    enforce {
        condition = local.node_to_node_encryption != null && core::try(local.node_to_node_encryption[0].enabled, false) && local.valid_version
        error_message = "Elasticsearch domain is not encrypting data sent between nodes"
    }
}
