# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-enis-source-destination-check-enabled.policy.hcl"
  ]
}
# Pass: interface type with source_dest_check enabled
resource "aws_network_interface" "compliant_interface" {
  attrs = {
    interface_type = "interface"
    source_dest_check = true
    subnet_id = "subnet-12345678"
  }
}

# Pass: EFA type with default source_dest_check (defaults to true)
resource "aws_network_interface" "efa_default" {
  attrs = {
    interface_type = "efa"
    subnet_id = "subnet-12345678"
    # source_dest_check not set, defaults to true
  }
}

# Fail: lambda type with source_dest_check disabled
resource "aws_network_interface" "non_compliant_lambda" {
  expect_failure = true
  attrs = {
    interface_type = "lambda"
    source_dest_check = false
    subnet_id = "subnet-12345678"
  }
}

# Pass: branch type with source_dest_check enabled
resource "aws_network_interface" "branch_compliant" {
  attrs = {
    interface_type = "branch"
    source_dest_check = true
    subnet_id = "subnet-12345678"
  }
}

# Fail: quicksight type with source_dest_check disabled
resource "aws_network_interface" "quicksight_non_compliant" {
  expect_failure = true
  attrs = {
    interface_type = "quicksight"
    source_dest_check = false
    subnet_id = "subnet-12345678"
  }
}

# Pass: nat_gateway type filtered out (not in allowed types)
resource "aws_network_interface" "nat_gateway_filtered" {
  attrs = {
    interface_type = "nat_gateway"
    source_dest_check = false
    subnet_id = "subnet-12345678"
  }
}

# Pass: aws_codestar_connections_managed type with source_dest_check enabled
resource "aws_network_interface" "codestar_compliant" {
  attrs = {
    interface_type = "aws_codestar_connections_managed"
    source_dest_check = true
    subnet_id = "subnet-12345678"
  }
}