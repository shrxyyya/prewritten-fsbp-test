# Copyright IBM Corp. 2026

policytest {
    targets = [
        "ec2-managedinstance-association-compliance-status-check.policy.hcl"
    ]
}

# Test 1: Compliant SSM Association - All Required Fields
resource "aws_ssm_association" "compliant_association_full" {
    attrs = {
        name = "AWS-UpdateSSMAgent"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        association_name = "UpdateSSMAgent"
        compliance_severity = "LOW"
        sync_compliance = "AUTO"
    }
}

# Test 2: Non-Compliant SSM Association - Missing Document Name
resource "aws_ssm_association" "missing_document_name" {
    expect_failure = true
    attrs = {
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        compliance_severity = "LOW"
        sync_compliance = "AUTO"
    }
}

# Test 3: Non-Compliant SSM Association - Missing Targets
resource "aws_ssm_association" "missing_targets" {
    expect_failure = true
    attrs = {
        name = "AWS-UpdateSSMAgent"
        compliance_severity = "LOW"
        sync_compliance = "AUTO"
    }
}

# Test 4: Non-Compliant SSM Association - Invalid Compliance Severity
resource "aws_ssm_association" "invalid_compliance_severity" {
    expect_failure = true
    attrs = {
        name = "AWS-UpdateSSMAgent"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        compliance_severity = "INVALID_SEVERITY"
        sync_compliance = "AUTO"
    }
}

# Test 5: Advisory Warning - Missing Compliance Severity
resource "aws_ssm_association" "missing_compliance_severity" {
    expect_failure = true
    attrs = {
        name = "AWS-UpdateSSMAgent"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        sync_compliance = "AUTO"
    }
}

# Test 6: Advisory Warning - Missing Sync Compliance
resource "aws_ssm_association" "missing_sync_compliance" {
    expect_failure = true
    attrs = {
        name = "AWS-UpdateSSMAgent"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        compliance_severity = "LOW"
    }
}

# Test 7: Advisory Warning - Manual Sync Compliance
resource "aws_ssm_association" "manual_sync_compliance" {
    expect_failure = true
    attrs = {
        name = "AWS-UpdateSSMAgent"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        compliance_severity = "LOW"
        sync_compliance = "MANUAL"
    }
}

# Test 8: Compliant EC2 Instance - Has IAM Profile and User Data
resource "aws_instance" "compliant_instance_full" {
    attrs = {
        ami = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        iam_instance_profile = "SSMInstanceProfile"
        user_data = "#!/bin/bash\nyum install -y amazon-ssm-agent\nsystemctl enable amazon-ssm-agent\nsystemctl start amazon-ssm-agent"
    }
}

# Test 9: Non-Compliant EC2 Instance - Missing IAM Profile
resource "aws_instance" "missing_iam_profile" {
    expect_failure = true
    attrs = {
        ami = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        user_data = "#!/bin/bash\nyum install -y amazon-ssm-agent"
    }
}

# Test 10: Advisory Warning - Missing User Data
resource "aws_instance" "missing_user_data" {
    expect_failure = true
    attrs = {
        ami = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        iam_instance_profile = "SSMInstanceProfile"
    }
}

# Test 11: Compliant Association - With Association Name
resource "aws_ssm_association" "compliant_with_association_name" {
    attrs = {
        name = "AWS-ConfigureAWSPackage"
        association_name = "InstallCloudWatchAgent"
        targets = [
            {
                key = "tag:Environment"
                values = ["Production"]
            }
        ]
        compliance_severity = "MEDIUM"
        sync_compliance = "AUTO"
    }
}

# Test 12: Compliant Association - Multiple Targets
resource "aws_ssm_association" "compliant_multiple_targets" {
    attrs = {
        name = "AWS-RunPatchBaseline"
        targets = [
            {
                key = "tag:Environment"
                values = ["Production"]
            },
            {
                key = "tag:Application"
                values = ["WebServer"]
            }
        ]
        compliance_severity = "HIGH"
        sync_compliance = "AUTO"
    }
}

# Test 13: Compliant Instance - User Data Base64
resource "aws_instance" "compliant_instance_base64_userdata" {
    attrs = {
        ami = "ami-0c55b159cbfafe1f0"
        instance_type = "t2.micro"
        iam_instance_profile = "SSMInstanceProfile"
        user_data_base64 = "IyEvYmluL2Jhc2gKeXVtIGluc3RhbGwgLXkgYW1hem9uLXNzbS1hZ2VudA=="
    }
}

# Test 14: Compliant Association - HIGH Severity
resource "aws_ssm_association" "compliant_high_severity" {
    attrs = {
        name = "AWS-RunPatchBaseline"
        targets = [
            {
                key = "InstanceIds"
                values = ["i-1234567890abcdef0"]
            }
        ]
        compliance_severity = "HIGH"
        sync_compliance = "AUTO"
    }
}

# Test 15: Compliant Association - CRITICAL Severity
resource "aws_ssm_association" "compliant_critical_severity" {
    attrs = {
        name = "AWS-ApplyPatchBaseline"
        targets = [
            {
                key = "tag:CriticalSystem"
                values = ["true"]
            }
        ]
        compliance_severity = "CRITICAL"
        sync_compliance = "AUTO"
    }
}
