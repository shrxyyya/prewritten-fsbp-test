terraform {
  required_version = ">= 1.15.0"

  cloud {

    organization = "nagateja-test-org"

    workspaces {
      name = "provider-test"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_subnet" "example_a" {
  vpc_id     = "vpc-12345678"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "example_b" {
  vpc_id     = "vpc-12345678"
  cidr_block = "10.0.2.0/24"
}

resource "aws_elasticache_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = [aws_subnet.example_a.id, aws_subnet.example_b.id]
}

resource "aws_elasticache_cluster" "example" {
  cluster_id                 = "example-cluster"
  engine                     = "redis"
  node_type                  = "cache.t3.micro"
  num_cache_nodes            = 1
  subnet_group_name          = aws_elasticache_subnet_group.example.name
  auto_minor_version_upgrade = true
  snapshot_retention_limit   = 15
}

resource "aws_elasticache_replication_group" "example" {
  replication_group_id       = "example-replication-group"
  description                = "example replication group"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2
  engine                     = "redis"
  subnet_group_name          = aws_elasticache_subnet_group.example.name
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "example-auth-token"
  snapshot_retention_limit   = 15
}
