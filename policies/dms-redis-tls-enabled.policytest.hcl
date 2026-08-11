# Copyright IBM Corp. 2026

policytest {
  targets = [
    "dms-redis-tls-enabled.policy.hcl"
  ]
}

# Test 1: PASS - Redis endpoint with explicit ssl-encryption
resource "aws_dms_endpoint" "redis_explicit" {
  attrs = {
    endpoint_id = "redis-endpoint-secure"
    endpoint_type = "target"
    engine_name = "redis"
    redis_settings = [
      {
        server_name = "redis.example.com"
        port = 6379
        auth_type = "auth-token"
        ssl_security_protocol = "ssl-encryption"
      }
    ]
  }
}

# Test 2: PASS - Redis endpoint with default ssl_security_protocol (defaults to ssl-encryption)
resource "aws_dms_endpoint" "redis_default" {
  attrs = {
    endpoint_id = "redis-endpoint-default"
    endpoint_type = "target"
    engine_name = "redis"
    redis_settings = [
      {
        server_name = "redis.example.com"
        port = 6379
        auth_type = "auth-token"
        # ssl_security_protocol not specified - defaults to "ssl-encryption"
      }
    ]
  }
}

# Test 3: FAIL - Redis endpoint with plaintext (TLS disabled)
resource "aws_dms_endpoint" "redis_plaintext" {
  expect_failure = true
  attrs = {
    endpoint_id = "redis-endpoint-insecure"
    endpoint_type = "target"
    engine_name = "redis"
    redis_settings = [
      {
        server_name = "redis.example.com"
        port = 6379
        auth_type = "auth-token"
        ssl_security_protocol = "plaintext"
      }
    ]
  }
}

# Test 4: Non-Redis endpoint should be filtered out (not evaluated)
resource "aws_dms_endpoint" "mysql" {
  attrs = {
    endpoint_id = "mysql-endpoint"
    endpoint_type = "source"
    engine_name = "mysql"
    # No redis_settings - this is a MySQL endpoint
  }
}