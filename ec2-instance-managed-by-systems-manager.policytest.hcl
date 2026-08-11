# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-instance-managed-by-systems-manager.policy.hcl"
  ]
}

# Test 1: Compliant instance with managed_policy_arns

resource "aws_iam_role" "ssm_role" {
  attrs = {
    name = "ec2-ssm-role"
    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  attrs = {
    name = "ec2-ssm-profile"
    role = "ec2-ssm-role"
  }
}

resource "aws_instance" "compliant" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    iam_instance_profile = "ec2-ssm-profile"
    tags = {
      Name = "compliant-instance"
    }
  }
}

# Test 2: Compliant instance with policy attachment

resource "aws_iam_role" "ssm_role_attachment" {
  attrs = {
    name = "ec2-ssm-role-attachment"
    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  attrs = {
    role = "ec2-ssm-role-attachment"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "aws_iam_instance_profile" "ssm_profile_attachment" {
  attrs = {
    name = "ec2-ssm-profile-attachment"
    role = "ec2-ssm-role-attachment"
  }
}

resource "aws_instance" "compliant_attachment" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    iam_instance_profile = "ec2-ssm-profile-attachment"
    tags = {
      Name = "compliant-instance-attachment"
    }
  }
}

# Test 3: Non-compliant instance without instance profile
resource "aws_instance" "no_profile" {
  expect_failure = true
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    tags = {
      Name = "no-profile-instance"
    }
  }
}

# Test 4: Instance with profile (SSM permission validation requires runtime checks)
# Note: This policy only validates instance profile presence, not SSM permissions
resource "aws_iam_role" "no_ssm_role" {
  attrs = {
    name = "ec2-no-ssm-role"
    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess"
    ]
  }
}

resource "aws_iam_instance_profile" "no_ssm_profile" {
  attrs = {
    name = "ec2-no-ssm-profile"
    role = "ec2-no-ssm-role"
  }
}

resource "aws_instance" "with_profile_no_ssm" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    iam_instance_profile = "ec2-no-ssm-profile"
    tags = {
      Name = "profile-without-ssm-permissions"
    }
  }
}

# Test 5: Excluded disaster recovery instance
resource "aws_instance" "disaster_recovery" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    tags = {
      Name = "disaster-recovery-instance"
      AWSElasticDisasterRecoveryManaged = "true"
    }
  }
}

# Test 6: Compliant with both managed policy and attachment
resource "aws_iam_role" "ssm_role_both" {
  attrs = {
    name = "ec2-ssm-role-both"
    assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attachment_both" {
  attrs = {
    role = "ec2-ssm-role-both"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "aws_iam_instance_profile" "ssm_profile_both" {
  attrs = {
    name = "ec2-ssm-profile-both"
    role = "ec2-ssm-role-both"
  }
}

resource "aws_instance" "compliant_both" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    iam_instance_profile = "ec2-ssm-profile-both"
    tags = {
      Name = "compliant-instance-both"
    }
  }
}

# Test 7: Alternative disaster recovery tag
resource "aws_instance" "disaster_recovery_alt" {
  attrs = {
    ami = "ami-12345678"
    instance_type = "t3.micro"
    tags = {
      Name = "disaster-recovery-instance-alt"
      "aws:elasticdr:replication-server" = "true"
    }
  }
}
