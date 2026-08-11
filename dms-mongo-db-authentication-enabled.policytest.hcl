# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-mongo-db-authentication-enabled.policy.hcl"
  ]
}

# Pass Case 1: MongoDB endpoint with scram_sha_1 authentication
resource "aws_dms_endpoint" "pass_with_scram_sha1" {
  attrs = {
    endpoint_id   = "mongodb-endpoint-1"
    endpoint_type = "source"
    engine_name   = "mongodb"
    mongodb_settings = [
      {
        auth_type      = "password"
        auth_mechanism = "scram_sha_1"
        auth_source    = "admin"
      }
    ]
    username      = "mongouser"
    password      = "mongopass"
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Pass Case 2: MongoDB endpoint with mongodb_cr authentication
resource "aws_dms_endpoint" "pass_with_mongodb_cr" {
  attrs = {
    endpoint_id   = "mongodb-endpoint-2"
    endpoint_type = "target"
    engine_name   = "mongodb"
    mongodb_settings = [
      {
        auth_type      = "password"
        auth_mechanism = "mongodb_cr"
        auth_source    = "admin"
      }
    ]
    username      = "mongouser"
    password      = "mongopass"
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Fail Case 1: MongoDB endpoint with auth_mechanism explicitly set to "default"
resource "aws_dms_endpoint" "fail_with_default_auth_mechanism" {
  expect_failure = true
  attrs = {
    endpoint_id   = "mongodb-endpoint-3"
    endpoint_type = "source"
    engine_name   = "mongodb"
    mongodb_settings = [
      {
        auth_type      = "password"
        auth_mechanism = "default"
        auth_source    = "admin"
      }
    ]
    username      = "mongouser"
    password      = "mongopass"
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Fail Case 2: MongoDB endpoint without mongodb_settings block
# auth_mechanism defaults to "default" when mongodb_settings is absent
resource "aws_dms_endpoint" "fail_missing_mongodb_settings" {
  expect_failure = true
  attrs = {
    endpoint_id   = "mongodb-endpoint-4"
    endpoint_type = "source"
    engine_name   = "mongodb"
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Fail Case 3: MongoDB endpoint with empty mongodb_settings block
# auth_mechanism defaults to "default" when the attribute is absent from the block
resource "aws_dms_endpoint" "fail_empty_mongodb_settings" {
  expect_failure = true
  attrs = {
    endpoint_id   = "mongodb-endpoint-5"
    endpoint_type = "source"
    engine_name   = "mongodb"
    mongodb_settings = [
      {}
    ]
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Fail Case 4: MongoDB endpoint with auth_mechanism missing from settings
# auth_mechanism defaults to "default" when not set
resource "aws_dms_endpoint" "fail_missing_auth_mechanism" {
  expect_failure = true
  attrs = {
    endpoint_id   = "mongodb-endpoint-6"
    endpoint_type = "source"
    engine_name   = "mongodb"
    mongodb_settings = [
      {
        auth_type   = "password"
        auth_source = "admin"
      }
    ]
    username      = "mongouser"
    password      = "mongopass"
    server_name   = "mongodb.example.com"
    port          = 27017
    database_name = "mydb"
  }
}

# Filter Test: Non-MongoDB endpoint is not evaluated (passes by filter)
resource "aws_dms_endpoint" "filter_non_mongodb_endpoint" {
  attrs = {
    endpoint_id   = "postgres-endpoint-1"
    endpoint_type = "source"
    engine_name   = "postgres"
    server_name   = "postgres.example.com"
    port          = 5432
    database_name = "mydb"
    username      = "pguser"
    password      = "pgpass"
  }
}