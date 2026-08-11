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

resource "aws_dms_replication_subnet_group" "example" {
  replication_subnet_group_id          = "example-subnet-group"
  replication_subnet_group_description = "example subnet group"
  subnet_ids                           = ["subnet-00000001", "subnet-00000002"]
}

resource "aws_dms_replication_instance" "example" {
  replication_instance_id    = "example-replication-instance"
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 20

  replication_subnet_group_id = aws_dms_replication_subnet_group.example.replication_subnet_group_id

  # dms-replication-not-public: must not be publicly accessible
  publicly_accessible = false

  # dms-replication-instance-multi-az-enabled: multi-AZ required
  multi_az = true

  # dms-auto-minor-version-upgrade-check: auto minor version upgrade required
  auto_minor_version_upgrade = true
}

# Standard relational endpoint (dms-endpoint-ssl-configured)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "example-source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"

  username      = "admin"
  password      = "example-password"
  server_name   = "source.example.com"
  port          = 3306
  database_name = "example"

  # dms-endpoint-ssl-configured: ssl_mode must be require / verify-ca / verify-full
  ssl_mode = "require"
}

# MongoDB endpoint (dms-mongo-db-authentication-enabled)
resource "aws_dms_endpoint" "mongodb" {
  endpoint_id   = "example-mongodb-endpoint"
  endpoint_type = "source"
  engine_name   = "mongodb"

  server_name = "mongo.example.com"
  port        = 27017

  # dms-endpoint-ssl-configured: SSL required for all endpoints
  ssl_mode = "require"

  mongodb_settings {
    # dms-mongo-db-authentication-enabled: auth_mechanism must not be "default"
    auth_mechanism = "scram-sha-1"
    auth_source    = "admin"
  }
}

# Neptune endpoint (dms-neptune-iam-authorization-enabled)
resource "aws_dms_endpoint" "neptune" {
  endpoint_id   = "example-neptune-endpoint"
  endpoint_type = "target"
  engine_name   = "neptune"

  server_name = "neptune.example.com"
  port        = 8182

  # dms-endpoint-ssl-configured
  ssl_mode = "require"

  # dms-neptune-iam-authorization-enabled: service_access_role must be set
  service_access_role = "arn:aws:iam::123456789012:role/dms-neptune-role"
}

# Redis endpoint (dms-redis-tls-enabled)
resource "aws_dms_endpoint" "redis" {
  endpoint_id   = "example-redis-endpoint"
  endpoint_type = "target"
  engine_name   = "redis"

  server_name = "redis.example.com"
  port        = 6379

  redis_settings {
    # dms-redis-tls-enabled: ssl_security_protocol must be "ssl-encryption"
    ssl_security_protocol = "ssl-encryption"
  }
}

# Replication task (dms-replication-task-targetdb-logging & sourcedb-logging)
resource "aws_dms_replication_task" "example" {
  replication_task_id      = "example-replication-task"
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.example.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.mongodb.endpoint_arn
  table_mappings           = jsonencode({ rules = [{ rule-type = "selection", rule-id = "1", rule-name = "1", object-locator = { schema-name = "%", table-name = "%" }, rule-action = "include" }] })

  # dms-replication-task-targetdb-logging & dms-replication-task-sourcedb-logging:
  # replication_task_settings must be set with logging enabled for
  # TARGET_APPLY, TARGET_LOAD (target policy) and SOURCE_CAPTURE, SOURCE_UNLOAD (source policy)
  replication_task_settings = jsonencode({
    Logging = {
      EnableLogging = true
      LogComponents = [
        { Id = "TARGET_APPLY", Severity = "LOGGER_SEVERITY_DEFAULT" },
        { Id = "TARGET_LOAD",  Severity = "LOGGER_SEVERITY_DEFAULT" },
        { Id = "SOURCE_CAPTURE", Severity = "LOGGER_SEVERITY_DEFAULT" },
        { Id = "SOURCE_UNLOAD",  Severity = "LOGGER_SEVERITY_DEFAULT" },
      ]
    }
  })
}
