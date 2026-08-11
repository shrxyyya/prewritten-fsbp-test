# Copyright IBM Corp. 2026

# RSA certificates managed by ACM should use a key length of at least 2,048 bits

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40.0, < 7.0.0"
    }
  }
}

input "acm-certificate-rsa-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_acm_certificate" "rsa_key_length_check" {
    enforcement_level = input.acm-certificate-rsa-check-enforcement-level
    # Only evaluate RSA certificates (exclude EC certificates)
    # Filter to certificates that have key_algorithm specified
    filter = attrs.key_algorithm != null

    locals {
        # Safe access to key_algorithm with default
        key_algorithm = core::try(attrs.key_algorithm, "")
        
        # Check if this is an RSA certificate
        is_rsa = core::contains(["RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096"], local.key_algorithm)
        
        # List of compliant RSA key algorithms (2048 bits or more)
        compliant_rsa_algorithms = ["RSA_2048", "RSA_3072", "RSA_4096"]
        
        # Check if RSA certificate meets minimum key length requirement
        is_compliant = core::contains(local.compliant_rsa_algorithms, local.key_algorithm)
    }

    # Only enforce on RSA certificates (EC certificates are excluded)
    enforce {
        condition = !local.is_rsa || local.is_compliant
        error_message = "ACM certificate uses ${local.key_algorithm} which does not meet the minimum 2048-bit key length requirement. RSA certificates must use RSA_2048, RSA_3072, or RSA_4096. Current algorithm: ${local.key_algorithm}"
    }
}
