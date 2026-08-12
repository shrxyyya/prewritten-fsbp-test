# Copyright IBM Corp. 2026

policytest {
    targets = [
        "dms-auto-minor-version-upgrade-check.policy.hcl"
    ]
}
# Test 1: PASS - auto_minor_version_upgrade enabled
resource "aws_dms_replication_instance" "pass_auto_upgrade_enabled" {
    attrs = {
        replication_instance_id    = "test-dms-instance"
        replication_instance_class = "dms.t3.micro"
        auto_minor_version_upgrade = true
    }
}

# Test 2: FAIL - auto_minor_version_upgrade disabled
resource "aws_dms_replication_instance" "fail_auto_upgrade_disabled" {
    expect_failure = true
    
    attrs = {
        replication_instance_id    = "test-dms-instance"
        replication_instance_class = "dms.t3.micro"
        auto_minor_version_upgrade = false
    }
}

# Test 3: FAIL - auto_minor_version_upgrade not specified (defaults to false)
resource "aws_dms_replication_instance" "fail_auto_upgrade_not_specified" {
    expect_failure = true
    
    attrs = {
        replication_instance_id    = "test-dms-instance"
        replication_instance_class = "dms.t3.micro"
        # auto_minor_version_upgrade not specified, defaults to false
    }
}

# Test 4: PASS - auto_minor_version_upgrade enabled with other attributes
resource "aws_dms_replication_instance" "pass_auto_upgrade_with_full_config" {
    attrs = {
        replication_instance_id    = "prod-dms-instance"
        replication_instance_class = "dms.c5.large"
        allocated_storage          = 100
        auto_minor_version_upgrade = true
        engine_version             = "3.4.7"
        multi_az                   = true
        publicly_accessible        = false
        tags = {
            Environment = "production"
        }
    }
}