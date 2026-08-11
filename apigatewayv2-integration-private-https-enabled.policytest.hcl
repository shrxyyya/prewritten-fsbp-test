# Copyright IBM Corp. 2026

policytest {
  targets = [
    "apigatewayv2-integration-private-https-enabled.policy.hcl"
    ]
}

# PASS: VPC_LINK integration with TLS configuration
resource "aws_apigatewayv2_integration" "pass_vpc_link_with_tls" {
  attrs = {
    api_id             = "abc123"
    integration_type   = "HTTP_PROXY"
    connection_type    = "VPC_LINK"
    connection_id      = "vpc-link-123"
    integration_uri    = "https://internal-api.example.com"
    integration_method = "POST"
    tls_config = [
      {
        server_name_to_verify = "internal-api.example.com"
      }
    ]
  }
}

# FAIL: VPC_LINK integration without TLS configuration
resource "aws_apigatewayv2_integration" "fail_vpc_link_without_tls" {
  expect_failure = true
  attrs = {
    api_id             = "abc123"
    integration_type   = "HTTP_PROXY"
    connection_type    = "VPC_LINK"
    connection_id      = "vpc-link-123"
    integration_uri    = "http://internal-api.example.com"
    integration_method = "POST"
  }
}

# PASS: INTERNET connection without TLS (filtered out by policy)
resource "aws_apigatewayv2_integration" "pass_internet_connection" {
  attrs = {
    api_id             = "abc123"
    integration_type   = "HTTP_PROXY"
    connection_type    = "INTERNET"
    integration_uri    = "https://public-api.example.com"
    integration_method = "GET"
  }
}

# FAIL: VPC_LINK with empty tls_config
resource "aws_apigatewayv2_integration" "fail_vpc_link_empty_tls" {
  expect_failure = true
  attrs = {
    api_id             = "abc123"
    integration_type   = "HTTP_PROXY"
    connection_type    = "VPC_LINK"
    connection_id      = "vpc-link-123"
    integration_uri    = "http://internal-api.example.com"
    integration_method = "POST"
    tls_config         = []
  }
}

# PASS: Default connection_type (INTERNET) without TLS
resource "aws_apigatewayv2_integration" "pass_default_connection_type" {
  attrs = {
    api_id             = "abc123"
    integration_type   = "HTTP_PROXY"
    integration_uri    = "https://api.example.com"
    integration_method = "GET"
  }
}