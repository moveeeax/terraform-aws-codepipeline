resource "aws_codepipeline" "this" {
  name     = var.name
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"

    # Omitting this block leaves artifacts on the AWS-managed key for S3.
    # Supplying a customer-managed key lets the artifact store be encrypted
    # with a key whose policy and rotation the caller controls.
    dynamic "encryption_key" {
      for_each = var.artifact_encryption_key_id == null ? [] : [var.artifact_encryption_key_id]

      content {
        id   = encryption_key.value
        type = "KMS"
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.source_repository_id
        BranchName       = var.source_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.build_project_name
      }
    }
  }

  tags = var.tags
}
