# Copyright IBM Corp. 2026

policytest {
  targets = [
    "codebuild-project-source-repo-url-check.policy.hcl"
  ]
}

# Test 1: Pass - Bitbucket primary source with CODECONNECTIONS authentication
resource "aws_codebuild_project" "pass_codeconnections" {
  attrs = {
    name = "test-project-codeconnections"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/myrepo"
      auth = {
        type = "CODECONNECTIONS"
        resource = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
      }
    }]
  }
}

# Test 2: Pass - Bitbucket primary source with SECRETS_MANAGER authentication
resource "aws_codebuild_project" "pass_secrets_manager" {
  attrs = {
    name = "test-project-secrets-manager"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/myrepo"
      auth = {
        type = "SECRETS_MANAGER"
        resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:bitbucket-creds"
      }
    }]
  }
}

# Test 3: Fail - Bitbucket primary source without authentication
resource "aws_codebuild_project" "fail_no_auth" {
  expect_failure = true
  attrs = {
    name = "test-project-no-auth"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/myrepo"
    }]
  }
}

# Test 4: Fail - Bitbucket primary source with invalid authentication type
resource "aws_codebuild_project" "fail_invalid_auth" {
  expect_failure = true
  attrs = {
    name = "test-project-invalid-auth"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/myrepo"
      auth = {
        type = "OAUTH"
        resource = "some-resource"
      }
    }]
  }
}

# Test 5: Pass - GitHub primary source (filter excludes non-Bitbucket)
resource "aws_codebuild_project" "pass_github" {
  attrs = {
    name = "test-project-github"
    source = [{
      type = "GITHUB"
      location = "https://github.com/myorg/myrepo"
    }]
  }
}

# Test 6: Pass - Bitbucket primary and secondary sources with proper auth
resource "aws_codebuild_project" "pass_multiple_sources" {
  attrs = {
    name = "test-project-multiple-sources"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/primary-repo"
      auth = {
        type = "CODECONNECTIONS"
        resource = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
      }
    }]
    secondary_sources = [
      {
        source_identifier = "secondary-bitbucket"
        type = "BITBUCKET"
        location = "https://bitbucket.org/myorg/secondary-repo"
        auth = {
          type = "SECRETS_MANAGER"
          resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:bitbucket-creds"
        }
      }
    ]
  }
}

# Test 7: Fail - Bitbucket primary (proper auth) with secondary source without auth
resource "aws_codebuild_project" "fail_secondary_no_auth" {
  expect_failure = true
  attrs = {
    name = "test-project-secondary-no-auth"
    source = [{
      type = "BITBUCKET"
      location = "https://bitbucket.org/myorg/primary-repo"
      auth = {
        type = "CODECONNECTIONS"
        resource = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
      }
    }]
    secondary_sources = [
      {
        source_identifier = "secondary-bitbucket"
        type = "BITBUCKET"
        location = "https://bitbucket.org/myorg/secondary-repo"
      }
    ]
  }
}

# Test 8: Pass - GitHub primary with Bitbucket secondary (filter excludes)
# Note: Filter only evaluates projects with Bitbucket PRIMARY source
resource "aws_codebuild_project" "pass_github_primary_bitbucket_secondary" {
  attrs = {
    name = "test-project-github-primary"
    source = [{
      type = "GITHUB"
      location = "https://github.com/myorg/primary-repo"
    }]
    secondary_sources = [
      {
        source_identifier = "secondary-bitbucket"
        type = "BITBUCKET"
        location = "https://bitbucket.org/myorg/secondary-repo"
        auth = {
          type = "CODECONNECTIONS"
          resource = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
        }
      }
    ]
  }
}