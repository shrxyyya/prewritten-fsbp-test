# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-encrypted-at-rest.policy.hcl"
    ]
}

# Test 1: PASS - Encrypted at rest
resource "aws_elasticsearch_domain" "pass_encrypted" {
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
        encrypt_at_rest = [{
            enabled = true
        }]
    }
}

# Test 2: FAIL - Not encrypted at rest
resource "aws_elasticsearch_domain" "fail_not_encrypted" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
        encrypt_at_rest = [{
            enabled = false
        }]
    }
}

# Test 3: FAIL - Missing encryption configuration
resource "aws_elasticsearch_domain" "fail_missing_config" {
    expect_failure = true
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
    }
}

# Test 4: PASS - Encrypted at rest with KMS key
resource "aws_elasticsearch_domain" "pass_encrypted_kms" {
    attrs = {
        domain_name = "test-domain"
        elasticsearch_version = "7.10"
        encrypt_at_rest = [{
            enabled = true
            kms_key_id = "alias/aws/es"
        }]
    }
}
