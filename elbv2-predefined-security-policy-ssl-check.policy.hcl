# Copyright IBM Corp. 2026

# Policy: ELB.17 - Application and Network Load Balancers with listeners should use recommended security policies

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

input "elbv2-predefined-security-policy-ssl-check-enforcement-level" {
  type = string
  default = "advisory"
}

resource_policy "aws_lb_listener" "elb17_recommended_ssl_policy" {
    enforcement_level = input.elbv2-predefined-security-policy-ssl-check-enforcement-level
    # Filter to only HTTPS (ALB) or TLS (NLB) listeners that require SSL policies
    filter = (core::try(attrs.protocol, "") == "HTTPS" || core::try(attrs.protocol, "") == "TLS")

    locals {
        # List of recommended SSL policies per AWS Security Hub ELB.17
        recommended_policies = [
            "ELBSecurityPolicy-TLS13-1-3-2021-06",
            "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04",
            "ELBSecurityPolicy-TLS13-1-2-Res-2021-06",
            "ELBSecurityPolicy-TLS13-1-2-Res-FIPS-2023-04",
            "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09",
            "ELBSecurityPolicy-TLS13-1-3-PQ-2025-09",
            "ELBSecurityPolicy-TLS13-1-2-Res-FIPS-PQ-2025-09",
            "ELBSecurityPolicy-TLS13-1-3-FIPS-PQ-2025-09"
        ]

        # Get the SSL policy configured on the listener (default is ELBSecurityPolicy-2016-08 if not specified)
        ssl_policy    = core::try(attrs.ssl_policy, "ELBSecurityPolicy-2016-08")
        listener_name = "${core::try(attrs.protocol, "listener")}:${core::try(attrs.port, 0)}"

        # Check if the SSL policy is in the recommended list
        is_recommended = core::contains(local.recommended_policies, local.ssl_policy)
    }

    enforce {
        condition = local.is_recommended
        error_message = "Load Balancer listener '${local.listener_name}' uses SSL policy '${local.ssl_policy}' which is not recommended. Please use one of the following recommended policies: ${core::join(", ", local.recommended_policies)}"
    }
}
