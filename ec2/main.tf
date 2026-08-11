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

resource "aws_ebs_snapshot_block_public_access" "example" {
  state = "block-all-sharing"
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/ec2/example"
}

resource "aws_ec2_client_vpn_endpoint" "example" {
  description            = "example-client-vpn-endpoint"
  server_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  client_cidr_block      = "10.0.0.0/22"
  split_tunnel           = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example-root"
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.example.name
    cloudwatch_log_stream = aws_cloudwatch_log_group.example.name
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  enable_network_address_usage_metrics = true
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "docker_registry_dkr" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "docker_registry_api" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_endpoint" "service" {
  vpc_id            = aws_vpc.example.id
  service_name      = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
}

resource "aws_vpc_block_public_access_options" "example" {
  internet_gateway_block_mode = "block-ingress"
}

resource "aws_flow_log" "example" {
  log_destination_type = "cloud-watch-logs"
  log_group_name       = aws_cloudwatch_log_group.example.name
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.example.id
}

resource "aws_ebs_encryption_by_default" "example" {
  enabled = true
}

resource "aws_network_interface" "example" {
  subnet_id         = aws_subnet.example.id
  source_dest_check = true
}

resource "aws_iam_instance_profile" "example" {
  name = "example-instance-profile"
  role = "example-role"
}

resource "aws_instance" "example" {
  ami                    = "ami-12345678"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.example.id
  vpc_security_group_ids = [aws_default_security_group.example.id]
  iam_instance_profile   = aws_iam_instance_profile.example.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/sdh"
    encrypted   = true
    volume_size = 10
  }
}

resource "aws_ec2_instance_metadata_defaults" "example" {
  http_tokens = "required"
}

resource "aws_launch_template" "example" {
  name = "example-launch-template"

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted   = true
      volume_size = 20
    }
  }
}

resource "aws_ssm_association" "example" {
  name = "AWS-UpdateSSMAgent"
}

resource "aws_network_acl" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_network_acl_rule" "example" {
  network_acl_id = aws_network_acl.example.id
  protocol       = "-1"
  rule_action    = "deny"
  rule_number    = 100
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_vpc_security_group_ingress_rule" "example" {
  security_group_id = aws_security_group.example.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_spot_fleet_request" "example" {
  iam_fleet_role      = "arn:aws:iam::123456789012:role/aws-ec2-spot-fleet-tagging-role"
  target_capacity     = 1
  allocation_strategy = "lowestPrice"
}

resource "aws_ec2_transit_gateway" "example" {
  auto_accept_shared_attachments = "disable"
}

resource "aws_vpn_connection" "example" {
  customer_gateway_id  = "cgw-12345678"
  transit_gateway_id   = aws_ec2_transit_gateway.example.id
  type                 = "ipsec.1"
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]
}

resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1a"
  encrypted         = true
  size              = 10
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_default_security_group" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_default_network_acl" "example" {
  default_network_acl_id = aws_vpc.example.default_network_acl_id
}

resource "aws_security_group" "example" {
  name   = "example-security-group"
  vpc_id = aws_vpc.example.id
}
