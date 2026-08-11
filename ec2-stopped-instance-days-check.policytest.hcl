# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ec2-stopped-instance-days-check.policy.hcl"
  ]
}

# Test 1: PASS - running instance is out of scope
resource "aws_instance" "running" {
  attrs = {
    instance_state = "running"
    instance_type  = "t2.micro"
    ami            = "ami-12345678"
    tags = {
      Name        = "running-instance"
      Environment = "production"
    }
  }
}

# Test 2: PASS - stopped instance with StoppedDate tag
resource "aws_instance" "stopped_with_tag" {
  attrs = {
    instance_state = "stopped"
    instance_type  = "t2.micro"
    ami            = "ami-12345678"
    tags = {
      Name        = "stopped-tagged"
      StoppedDate = "2025-04-25T00:00:00Z"
    }
  }
}

# Test 3: PASS - pending instance (not stopped)
resource "aws_instance" "pending" {
  attrs = {
    instance_state = "pending"
    instance_type  = "t3.small"
    ami            = "ami-87654321"
    tags = {
      Name = "pending-instance"
    }
  }
}

# Test 4: PASS - stopping instance (transitional, not stopped)
resource "aws_instance" "stopping" {
  attrs = {
    instance_state = "stopping"
    instance_type  = "t2.medium"
    ami            = "ami-11223344"
    tags = {
      Name = "stopping-instance"
    }
  }
}

# Test 5: PASS - terminated instance (not stopped)
resource "aws_instance" "terminated" {
  attrs = {
    instance_state = "terminated"
    instance_type  = "t2.micro"
    ami            = "ami-66778899"
    tags = {
      Name = "terminated-instance"
    }
  }
}

# Test 6: PASS - instance without instance_state (cannot be classified as stopped)
resource "aws_instance" "no_state" {
  attrs = {
    instance_type = "t2.micro"
    ami           = "ami-99887766"
    tags = {
      Name = "instance-without-state"
    }
  }
}

# Test 7: FAIL - stopped instance without StoppedDate tag
resource "aws_instance" "stopped_missing_date" {
  expect_failure = true
  attrs = {
    instance_state = "stopped"
    instance_type  = "t2.small"
    ami            = "ami-55443322"
    tags = {
      Environment = "test"
    }
  }
}

# Test 8: FAIL - stopped instance with no tags block at all
resource "aws_instance" "stopped_no_tags" {
  expect_failure = true
  attrs = {
    instance_state = "stopped"
    instance_type  = "t2.micro"
    ami            = "ami-12345678"
  }
}
