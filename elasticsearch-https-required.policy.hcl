# Copyright IBM Corp. 2026

# Connections to Elasticsearch domains should be encrypted using the latest TLS security policy

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elasticsearch-https-required-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_elasticsearch_domain" "tls_security_policy" {
    enforcement_level = input.elasticsearch-https-required-enforcement-level
    filter = core::try(attrs.domain_endpoint_options, null) != null || core::length(core::try(attrs.domain_endpoint_options, [])) > 0

    locals {
        endpoint_options = core::try(attrs.domain_endpoint_options[0], {})
        enforce_https = core::try(local.endpoint_options.enforce_https, true)
        tls_policy = core::try(local.endpoint_options.tls_security_policy, "")
    }

    enforce {
        condition = local.enforce_https == true
        error_message = "Elasticsearch domain must have HTTPS enforcement enabled. Set 'domain_endpoint_options.enforce_https = true' to encrypt connections"
    }

    enforce {
        condition = local.tls_policy == "Policy-Min-TLS-1-2-PFS-2023-10"
        error_message = "Elasticsearch domain must use the latest TLS security policy 'Policy-Min-TLS-1-2-PFS-2023-10'. Update 'domain_endpoint_options.tls_security_policy' to the required version"
    }
}
