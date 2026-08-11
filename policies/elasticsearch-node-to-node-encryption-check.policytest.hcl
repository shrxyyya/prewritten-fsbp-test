# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-node-to-node-encryption-check.policy.hcl"
    ]
}

# Test 1: PASS - Node-to-node encryption is enabled
resource "aws_elasticsearch_domain" "pass_node_encryption" {
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
        node_to_node_encryption = [{
            enabled = true
        }]
    }
}

# Test 2: FAIL - Node-to-node encryption is enabled but unsupported version
resource "aws_elasticsearch_domain" "fail_unsupported_version" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "5.6"
        node_to_node_encryption = [{
            enabled = true
        }]
    }
}

# Test 3: FAIL - Node-to-node encryption is enabled but missing version
resource "aws_elasticsearch_domain" "fail_missing_version" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        node_to_node_encryption = [{
            enabled = true
        }]
    }
}

# Test 4: FAIL - Node-to-node encryption is disabled
resource "aws_elasticsearch_domain" "fail_node_encryption" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
        node_to_node_encryption = [{
            enabled = false
        }]
    }
}

# Test 5: FAIL - Node-to-node encryption is missing
resource "aws_elasticsearch_domain" "missing_node_encryption" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
    }
}
