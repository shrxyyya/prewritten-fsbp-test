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

resource "aws_api_gateway_rest_api" "example" {
  name = "example-api"
}

resource "aws_api_gateway_client_certificate" "example" {
  description = "example client certificate"
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/apigateway/example"
}

resource "aws_api_gateway_stage" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.example.id

  # api-gw-ssl-enabled: client certificate for backend auth
  client_certificate_id = aws_api_gateway_client_certificate.example.id

  # api-gw-xray-enabled: X-Ray tracing
  xray_tracing_enabled = true

  # api-gw-execution-logging-enabled: access log settings
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.example.arn
  }

  # api-gw-associated-with-waf: web_acl_arn set via aws_wafv2_web_acl_association
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = "*/*"

  settings {
    # api-gw-execution-logging-enabled: execution logging level
    logging_level = "ERROR"

    # api-gw-cache-encrypted: cache encryption (caching_enabled must be true to trigger filter)
    caching_enabled      = true
    cache_data_encrypted = true
  }
}

resource "aws_api_gateway_domain_name" "example" {
  domain_name     = "api.example.com"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"

  # apigateway-domain-name-tls-check: recommended TLS security policy
  security_policy = "SecurityPolicy_TLS13_1_3_2025_09"
}

resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "v2_example" {
  name = "/aws/apigateway/v2/example"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id      = aws_apigatewayv2_api.example.id
  name        = "prod"
  auto_deploy = true

  # api-gwv2-access-logs-enabled & api-gw-execution-logging-enabled: access logs
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.v2_example.arn
    format          = "$context.requestId $context.status $context.error.message"
  }

  # api-gw-execution-logging-enabled: execution logging via default_route_settings
  default_route_settings {
    logging_level = "ERROR"
  }
}

resource "aws_apigatewayv2_vpc_link" "example" {
  name               = "example-vpc-link"
  security_group_ids = []
  subnet_ids         = []
}

resource "aws_apigatewayv2_integration" "example" {
  api_id             = aws_apigatewayv2_api.example.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "https://internal.example.com"
  integration_method = "ANY"

  # apigatewayv2-integration-private-https-enabled: VPC_LINK connection with TLS config
  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.example.id

  tls_config {
    server_name_to_verify = "internal.example.com"
  }
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "ANY /{proxy+}"

  # api-gwv2-authorization-type-configured: must not be NONE
  authorization_type = "AWS_IAM"
}
