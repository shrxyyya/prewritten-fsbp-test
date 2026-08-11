# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-transit-gateway-auto-vpc-attach-disabled.policy.hcl"
    ]
}

# Test 1: PASS - Transit Gateway with auto-accept explicitly disabled
resource "aws_ec2_transit_gateway" "compliant_explicit" {
    attrs = {
        auto_accept_shared_attachments = "disable"
        amazon_side_asn                = 64512
        description                    = "Transit Gateway with auto-accept disabled"
    }
}

# Test 2: PASS - Transit Gateway without auto-accept attribute (uses default)
resource "aws_ec2_transit_gateway" "compliant_default" {
    attrs = {
        amazon_side_asn = 64512
        description     = "Transit Gateway using default auto-accept setting"
    }
}

# Test 3: FAIL - Transit Gateway with auto-accept enabled
resource "aws_ec2_transit_gateway" "non_compliant" {
    expect_failure = true
    attrs = {
        auto_accept_shared_attachments = "enable"
        amazon_side_asn                = 64512
        description                    = "Transit Gateway with auto-accept enabled"
    }
}
