# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-data-node-fault-tolerance.policy.hcl"
    ]
}

# Test 1: PASS - 3 data nodes with zone awareness enabled
resource "aws_elasticsearch_domain" "pass_3_nodes_zone_aware" {
  attrs = {
    domain_name = "compliant-domain-3-nodes"
    cluster_config = [
      {
        instance_count = 3
        instance_type = "t3.small.elasticsearch"
        zone_awareness_enabled = true
        zone_awareness_config = [
          {
            availability_zone_count = 3
          }
        ]
      }
    ]
  }
}

# Test 2: PASS - 6 data nodes (multiple of 3) with zone awareness enabled
resource "aws_elasticsearch_domain" "pass_6_nodes_zone_aware" {
  attrs = {
    domain_name = "compliant-domain-6-nodes"
    cluster_config = [
      {
        instance_count = 6
        instance_type = "t3.small.elasticsearch"
        zone_awareness_enabled = true
        zone_awareness_config = [
          {
            availability_zone_count = 3
          }
        ]
      }
    ]
  }
}

# Test 3: FAIL - Only 1 data node
resource "aws_elasticsearch_domain" "fail_1_node" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain-1-node"
    cluster_config = [
      {
        instance_count = 1
        instance_type = "t3.small.elasticsearch"
        zone_awareness_enabled = true
      }
    ]
  }
}

# Test 4: FAIL - Only 2 data nodes
resource "aws_elasticsearch_domain" "fail_2_nodes" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain-2-nodes"
    cluster_config = [
      {
        instance_count = 2
        instance_type = "t3.small.elasticsearch"
        zone_awareness_enabled = true
      }
    ]
  }
}

# Test 5: FAIL - 3 nodes but zone awareness disabled
resource "aws_elasticsearch_domain" "fail_zone_awareness_disabled" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain-no-zone-awareness"
    cluster_config = [
      {
        instance_count = 3
        instance_type = "t3.small.elasticsearch"
        zone_awareness_enabled = false
      }
    ]
  }
}

# Test 6: FAIL - 3 nodes but zone awareness missing
resource "aws_elasticsearch_domain" "fail_zone_awareness_missing" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain-no-zone-awareness"
    cluster_config = [
      {
        instance_count = 3
        instance_type = "t3.small.elasticsearch"
      }
    ]
  }
}
