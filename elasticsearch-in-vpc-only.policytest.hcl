# Copyright IBM Corp. 2026

policytest {
    targets = [
        "elasticsearch-in-vpc-only.policy.hcl"
    ]
}

# Test 1: PASS - Elasticsearch domain with vpc_options and single subnet
resource "aws_elasticsearch_domain" "compliant_single" {
  attrs = {
    domain_name = "compliant-domain-single"
    elasticsearch_version = "7.10"
    vpc_options = [
      {
        subnet_ids = ["subnet-12345678"]
        security_group_ids = ["sg-12345678"]
      }
    ]
  }
}

# Test 2: PASS - Elasticsearch domain with vpc_options and multiple subnets
resource "aws_elasticsearch_domain" "compliant_multi" {
  attrs = {
    domain_name = "compliant-domain-multi"
    elasticsearch_version = "7.10"
    vpc_options = [
      {
        subnet_ids = ["subnet-12345678", "subnet-87654321", "subnet-11111111"]
        security_group_ids = ["sg-12345678", "sg-87654321"]
      }
    ]
  }
}

# Test 3: FAIL - Elasticsearch domain without vpc_options
resource "aws_elasticsearch_domain" "non_compliant_no_vpc" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-domain"
    elasticsearch_version = "7.10"
    cluster_config = [
      {
        instance_type = "t3.small.elasticsearch"
        instance_count = 1
      }
    ]
  }
}

# Test 4: FAIL - Elasticsearch domain with vpc_options but empty subnet_ids
resource "aws_elasticsearch_domain" "non_compliant_empty_subnets" {
  expect_failure = true
  attrs = {
    domain_name = "non-compliant-empty-subnets"
    elasticsearch_version = "7.10"
    vpc_options = [
      {
        subnet_ids = []
        security_group_ids = ["sg-12345678"]
      }
    ]
  }
}
