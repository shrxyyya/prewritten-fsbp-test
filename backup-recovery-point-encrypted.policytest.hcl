# Copyright IBM Corp. 2026

policytest {
    targets = [
        "backup-recovery-point-encrypted.policy.hcl"
    ]
}

# Test 1: PASS - Recovery point is encrypted
resource "aws_backup_framework" "pass_encrypted" {
    attrs = {
        name = "test-framework-pass-encrypted"
        control = [{
            name = "BACKUP_RECOVERY_POINT_ENCRYPTED"
        }]
    }
}

# Test 2: FAIL - Recovery point is not encrypted
resource "aws_backup_framework" "fail_encrypted" {
    expect_failure = true
    attrs = {
        name = "test-framework-fail-encrypted"
        control = {
            name = "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
        }
    }
}

# Test 3: FAIL - Empty control block
resource "aws_backup_framework" "fail_empty" {
    expect_failure = true
    attrs = {
        name = "test-framework-fail-empty"
    }
}

# Test 4: PASS - Multiple control blocks including the encryption control
resource "aws_backup_framework" "pass_multiple_controls_with_encryption" {
    attrs = {
        name = "test-framework-pass-multiple-controls"
        control = [
            {
                name = "BACKUP_RECOVERY_POINT_MINIMUM_RETENTION_CHECK"
            },
            {
                name = "BACKUP_RECOVERY_POINT_ENCRYPTED"
            },
            {
                name = "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            }
        ]
    }
}

# Test 5: FAIL - Multiple control blocks but missing the encryption control
resource "aws_backup_framework" "fail_multiple_controls_without_encryption" {
    expect_failure = true
    attrs = {
        name = "test-framework-fail-multiple-controls-no-encryption"
        control = [
            {
                name = "BACKUP_RECOVERY_POINT_MINIMUM_RETENTION_CHECK"
            },
            {
                name = "BACKUP_RECOVERY_POINT_MANUAL_DELETION_DISABLED"
            },
            {
                name = "BACKUP_PLAN_MIN_FREQUENCY_AND_MIN_RETENTION_CHECK"
            }
        ]
    }
}

# Test 6: FAIL - Control block present but with empty name
resource "aws_backup_framework" "fail_control_empty_name" {
    expect_failure = true
    attrs = {
        name = "test-framework-fail-control-empty-name"
        control = [
            {
                name = ""
            }
        ]
    }
}

# Test 7: FAIL - Control block with similar but incorrect name
resource "aws_backup_framework" "fail_similar_control_name" {
    expect_failure = true
    attrs = {
        name = "test-framework-fail-similar-name"
        control = [
            {
                name = "BACKUP_RECOVERY_POINT_ENCRYPT"
            },
            {
                name = "BACKUP_RECOVERY_POINT_ENCRYPTED_CHECK"
            }
        ]
    }
}
