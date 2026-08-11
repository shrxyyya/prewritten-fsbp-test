# Copyright IBM Corp. 2026

policytest {
  targets = [
    "emr-master-no-public-ip.policy.hcl"
  ]
}
# Pass case: EMR cluster with subnet that has map_public_ip_on_launch = false
resource "aws_emr_cluster" "pass_private_subnet_with_subnet_id" {
  attrs = {
    name = "compliant-cluster"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      subnet_id = "subnet-12345678"
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

resource "aws_subnet" "private_subnet_1" {
  attrs = {
    id = "subnet-12345678"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = false
  }
}

# Fail case: EMR cluster with subnet that has map_public_ip_on_launch = true
resource "aws_emr_cluster" "fail_public_subnet_with_subnet_id" {
  expect_failure = true
  attrs = {
    name = "non-compliant-cluster"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      subnet_id = "subnet-87654321"
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

resource "aws_subnet" "public_subnet_1" {
  attrs = {
    id = "subnet-87654321"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
  }
}

# Pass case: EMR cluster with subnet_ids list pointing to private subnet
resource "aws_emr_cluster" "pass_private_subnet_with_subnet_ids" {
  attrs = {
    name = "compliant-cluster-multi"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      subnet_ids = ["subnet-11111111", "subnet-22222222"]
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

resource "aws_subnet" "private_subnet_2" {
  attrs = {
    id = "subnet-11111111"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = false
  }
}

resource "aws_subnet" "private_subnet_3" {
  attrs = {
    id = "subnet-22222222"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = false
  }
}

# Fail case: EMR cluster with subnet_ids list where first subnet is public
resource "aws_emr_cluster" "fail_public_subnet_with_subnet_ids" {
  expect_failure = true
  attrs = {
    name = "non-compliant-cluster-multi"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      subnet_ids = ["subnet-99999999", "subnet-88888888"]
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

resource "aws_subnet" "public_subnet_2" {
  attrs = {
    id = "subnet-99999999"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.5.0/24"
    map_public_ip_on_launch = true
  }
}

resource "aws_subnet" "private_subnet_4" {
  attrs = {
    id = "subnet-88888888"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.6.0/24"
    map_public_ip_on_launch = false
  }
}

# Fail case: EMR cluster without ec2_attributes
resource "aws_emr_cluster" "fail_missing_ec2_attributes" {
  expect_failure = true
  attrs = {
    name = "no-ec2-attrs-cluster"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
  }
}

# Fail case: EMR cluster with ec2_attributes but no subnet configuration
resource "aws_emr_cluster" "fail_missing_subnet_config" {
  expect_failure = true
  attrs = {
    name = "no-subnet-cluster"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

# Fail case: EMR cluster with subnet_ids where a non-first subnet is public.
# With instance fleets, EMR may launch the master in any of these subnets,
# so any public subnet in the list must cause failure.
resource "aws_emr_cluster" "fail_mixed_subnet_ids_non_first_public" {
  expect_failure = true
  attrs = {
    name = "mixed-subnets-cluster"
    release_label = "emr-6.10.0"
    service_role = "arn:aws:iam::123456789012:role/EMR_DefaultRole"
    ec2_attributes = {
      subnet_ids = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
      instance_profile = "arn:aws:iam::123456789012:instance-profile/EMR_EC2_DefaultRole"
    }
  }
}

resource "aws_subnet" "mixed_private_subnet" {
  attrs = {
    id = "subnet-aaaaaaaa"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.7.0/24"
    map_public_ip_on_launch = false
  }
}

resource "aws_subnet" "mixed_public_subnet" {
  attrs = {
    id = "subnet-bbbbbbbb"
    vpc_id = "vpc-12345678"
    cidr_block = "10.0.8.0/24"
    map_public_ip_on_launch = true
  }
}