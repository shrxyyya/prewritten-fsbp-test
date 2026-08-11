# Copyright IBM Corp. 2026

# Amazon EMR security configurations should be encrypted in transit

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "emr-security-configuration-encryption-transit-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_emr_security_configuration" "emr-security-configuration-encryption-transit" {
    enforcement_level = input.emr-security-configuration-encryption-transit-enforcement-level
    locals {
        config = core::jsondecode(attrs.configuration)
    }

    enforce {
        condition = core::try(local.config.EncryptionConfiguration.EnableInTransitEncryption, false)
        error_message = "The EMR security configuration does not have the encryption in transit enabled"
    }
}
