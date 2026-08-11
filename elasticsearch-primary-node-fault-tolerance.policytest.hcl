# Copyright IBM Corp. 2026

policytest {
  targets = [
    "elasticsearch-primary-node-fault-tolerance.policy.hcl"
  ]
}

# Test 1: PASS - aws_elasticsearch_domain with 3 dedicated master nodes
resource "aws_elasticsearch_domain" "elasticsearch_pass_three_masters" {
  attrs = {
    domain_name = "test-domain"
    cluster_config = [
      {
        dedicated_master_enabled = true
        dedicated_master_count = 3
        dedicated_master_type = "m5.large.elasticsearch"
        instance_type = "m5.large.elasticsearch"
        instance_count = 2
      }
    ]
  }
}

# Test 2: PASS - aws_elasticsearch_domain with 5 dedicated master nodes
resource "aws_elasticsearch_domain" "elasticsearch_pass_five_masters" {
  attrs = {
    domain_name = "test-domain-five"
    cluster_config = [
      {
        dedicated_master_enabled = true
        dedicated_master_count = 5
        dedicated_master_type = "m5.large.elasticsearch"
        instance_type = "m5.large.elasticsearch"
        instance_count = 3
      }
    ]
  }
}

# Test 3: FAIL - aws_elasticsearch_domain with dedicated_master_enabled=false
resource "aws_elasticsearch_domain" "elasticsearch_fail_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "test-domain-disabled"
    cluster_config = [
      {
        dedicated_master_enabled = false
        instance_type = "m5.large.elasticsearch"
        instance_count = 2
      }
    ]
  }
}

# Test 4: FAIL - aws_elasticsearch_domain with only 2 dedicated master nodes
resource "aws_elasticsearch_domain" "elasticsearch_fail_insufficient_count" {
  expect_failure = true
  attrs = {
    domain_name = "test-domain-two"
    cluster_config = [
      {
        dedicated_master_enabled = true
        dedicated_master_count = 2
        dedicated_master_type = "m5.large.elasticsearch"
        instance_type = "m5.large.elasticsearch"
        instance_count = 2
      }
    ]
  }
}

# Test 5: FAIL - aws_elasticsearch_domain with dedicated_master_enabled but no count
resource "aws_elasticsearch_domain" "elasticsearch_fail_no_count" {
  expect_failure = true
  attrs = {
    domain_name = "test-domain-no-count"
    cluster_config = [
      {
        dedicated_master_enabled = true
        dedicated_master_type = "m5.large.elasticsearch"
        instance_type = "m5.large.elasticsearch"
        instance_count = 2
      }
    ]
  }
}


# Test 6: FAIL - aws_elasticsearch_domain with empty cluster_config array
resource "aws_elasticsearch_domain" "elasticsearch_fail_empty_config" {
  expect_failure = true
  attrs = {
    domain_name = "test-domain-empty-config"
    cluster_config = []
  }
}
