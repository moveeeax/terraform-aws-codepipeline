# terraform-aws-codepipeline

Terraform module that manages an [AWS
CodePipeline](https://aws.amazon.com/codepipeline/) pipeline. It creates a
two-stage pipeline that pulls source from a repository over a CodeStar
connection and runs a CodeBuild project, wiring artifacts through an S3 store.

## Usage

```hcl
module "codepipeline" {
  source = "github.com/cybercapybara/terraform-aws-codepipeline"

  name                 = "app-pipeline"
  role_arn             = aws_iam_role.pipeline.arn
  artifact_bucket      = "pipeline-artifacts-prod"
  connection_arn       = aws_codestarconnections_connection.this.arn
  source_repository_id = "cybercapybara/app"
  build_project_name   = "app-build"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                   | Description                                             | Type          | Default   | Required |
|------------------------|---------------------------------------------------------|---------------|-----------|:--------:|
| `name`                 | Name of the pipeline.                                   | `string`      | n/a       |   yes    |
| `role_arn`             | ARN of the CodePipeline service role.                   | `string`      | n/a       |   yes    |
| `artifact_bucket`      | S3 bucket used to store pipeline artifacts.             | `string`      | n/a       |   yes    |
| `source_repository_id` | Full repository identifier for the source stage.        | `string`      | n/a       |   yes    |
| `source_branch`        | Branch the source stage tracks.                         | `string`      | `"main"`  |    no    |
| `connection_arn`       | ARN of the CodeStar connection.                         | `string`      | n/a       |   yes    |
| `build_project_name`   | Name of the CodeBuild project.                          | `string`      | n/a       |   yes    |
| `tags`                 | Tags applied to the pipeline.                           | `map(string)` | `{}`      |    no    |

## Outputs

| Name   | Description                                        |
|--------|----------------------------------------------------|
| `id`   | ID of the pipeline.                                |
| `arn`  | ARN of the pipeline.                               |
| `name` | Name of the pipeline.                              |

## License

[MIT](LICENSE)
