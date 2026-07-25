# Requires Terraform >= 1.7 (or OpenTofu >= 1.7) for `mock_provider`. The module
# itself still supports >= 1.5; this requirement applies to running the tests only.
mock_provider "aws" {}

variables {
  name                 = "example-pipeline"
  role_arn             = "arn:aws:iam::123456789012:role/example-pipeline"
  artifact_bucket      = "example-pipeline-artifacts"
  connection_arn       = "arn:aws:codeconnections:us-east-1:123456789012:connection/11111111-2222-3333-4444-555555555555"
  source_repository_id = "example-org/example-app"
  build_project_name   = "example-build"
}

run "defaults_omit_customer_managed_key" {
  assert {
    condition     = length(one(aws_codepipeline.this.artifact_store).encryption_key) == 0
    error_message = "No encryption_key block should be emitted when artifact_encryption_key_id is unset."
  }

  assert {
    condition     = one(aws_codepipeline.this.artifact_store).type == "S3"
    error_message = "The artifact store must be of type S3."
  }

  assert {
    condition     = one(aws_codepipeline.this.artifact_store).location == "example-pipeline-artifacts"
    error_message = "The artifact store must point at the supplied bucket."
  }
}

run "customer_managed_key_is_wired_into_the_artifact_store" {
  variables {
    artifact_encryption_key_id = "arn:aws:kms:us-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = length(one(aws_codepipeline.this.artifact_store).encryption_key) == 1
    error_message = "Supplying artifact_encryption_key_id must emit exactly one encryption_key block."
  }

  assert {
    condition     = one(one(aws_codepipeline.this.artifact_store).encryption_key).type == "KMS"
    error_message = "The artifact store encryption key must be of type KMS."
  }

  assert {
    condition     = one(one(aws_codepipeline.this.artifact_store).encryption_key).id == "arn:aws:kms:us-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    error_message = "The artifact store must use the supplied KMS key."
  }
}

run "kms_alias_is_accepted" {
  variables {
    artifact_encryption_key_id = "alias/codepipeline-artifacts"
  }

  assert {
    condition     = one(one(aws_codepipeline.this.artifact_store).encryption_key).id == "alias/codepipeline-artifacts"
    error_message = "A KMS alias must be accepted as the artifact store key."
  }
}

run "stages_are_wired_source_to_build" {
  assert {
    condition     = length(aws_codepipeline.this.stage) == 2
    error_message = "The pipeline must have a Source stage and a Build stage."
  }

  assert {
    condition     = aws_codepipeline.this.stage[0].action[0].configuration["BranchName"] == "main"
    error_message = "The source stage must default to the main branch."
  }

  assert {
    condition = length(setintersection(
      toset(one(aws_codepipeline.this.stage[0].action).output_artifacts),
      toset(one(aws_codepipeline.this.stage[1].action).input_artifacts),
    )) == 1
    error_message = "The build stage must consume the artifact the source stage produces."
  }
}

run "rejects_bucket_arn_in_place_of_bucket_name" {
  command = plan

  variables {
    artifact_bucket = "arn:aws:s3:::example-pipeline-artifacts"
  }

  expect_failures = [var.artifact_bucket]
}

run "rejects_non_role_arn" {
  command = plan

  variables {
    role_arn = "arn:aws:iam::123456789012:user/not-a-role"
  }

  expect_failures = [var.role_arn]
}

run "rejects_bare_repository_name" {
  command = plan

  variables {
    source_repository_id = "example-app"
  }

  expect_failures = [var.source_repository_id]
}

run "rejects_empty_source_branch" {
  command = plan

  variables {
    source_branch = "  "
  }

  expect_failures = [var.source_branch]
}

run "rejects_non_connection_arn" {
  command = plan

  variables {
    connection_arn = "arn:aws:codebuild:us-east-1:123456789012:project/example-build"
  }

  expect_failures = [var.connection_arn]
}

run "rejects_invalid_pipeline_name" {
  command = plan

  variables {
    name = "pipeline with spaces"
  }

  expect_failures = [var.name]
}

run "rejects_non_kms_encryption_key" {
  command = plan

  variables {
    artifact_encryption_key_id = "not-a-key"
  }

  expect_failures = [var.artifact_encryption_key_id]
}
