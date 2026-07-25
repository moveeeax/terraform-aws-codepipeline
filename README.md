# terraform-aws-codepipeline

Terraform module that manages an [AWS
CodePipeline](https://aws.amazon.com/codepipeline/) pipeline. It creates a
two-stage pipeline that pulls source from a repository over a CodeStar
connection and runs a CodeBuild project, wiring artifacts through an S3 store.

## Usage

```hcl
module "codepipeline" {
  source = "github.com/moveeeax/terraform-aws-codepipeline"

  name                 = "app-pipeline"
  role_arn             = aws_iam_role.pipeline.arn
  artifact_bucket      = "pipeline-artifacts-prod"
  connection_arn       = aws_codestarconnections_connection.this.arn
  source_repository_id = "moveeeax/app"
  build_project_name   = "app-build"

  artifact_encryption_key_id = aws_kms_key.artifacts.arn

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## What this module does not manage

The module manages the pipeline only. The three resources it points at are the
caller's, deliberately, so that this module never has to hold broad permissions
of its own:

- **The IAM role** (`role_arn`). Scope it to the specific artifact bucket, the
  specific CodeBuild project, and the specific connection this pipeline uses.
  A pipeline role is a classic place to end up with `s3:*` on `*`.
- **The artifact bucket** (`artifact_bucket`). Give it
  `aws_s3_bucket_public_access_block` with all four settings on, versioning,
  and default encryption. CodePipeline will happily write to a public bucket.
- **The KMS key** (`artifact_encryption_key_id`). Optional. When unset, the
  artifact store falls back to the AWS managed key for S3, which cannot carry a
  key policy of your own and is shared across the account. Pass a
  customer-managed key when the artifacts are sensitive or when cross-account
  access needs to be controlled by key policy.

Source is pulled over a CodeConnections connection rather than a raw webhook, so
there is no shared webhook secret for this module to store or leak.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

All inputs below are validated at plan time, so a bucket ARN passed where a
bucket name belongs fails immediately instead of at apply.

| Name                         | Description                                                          | Type          | Default  | Required |
|------------------------------|----------------------------------------------------------------------|---------------|----------|:--------:|
| `name`                       | Name of the pipeline.                                                | `string`      | n/a      |   yes    |
| `role_arn`                   | ARN of the CodePipeline service role.                                | `string`      | n/a      |   yes    |
| `artifact_bucket`            | S3 bucket name used to store pipeline artifacts.                     | `string`      | n/a      |   yes    |
| `artifact_encryption_key_id` | KMS key ARN, key ID, or alias for the artifact store.                | `string`      | `null`   |    no    |
| `source_repository_id`       | Full repository identifier for the source stage, as `owner/repo`.    | `string`      | n/a      |   yes    |
| `source_branch`              | Branch the source stage tracks.                                      | `string`      | `"main"` |    no    |
| `connection_arn`             | ARN of the CodeConnections connection.                               | `string`      | n/a      |   yes    |
| `build_project_name`         | Name of the CodeBuild project.                                       | `string`      | n/a      |   yes    |
| `tags`                       | Tags applied to the pipeline.                                        | `map(string)` | `{}`     |    no    |

## Outputs

| Name   | Description                                        |
|--------|----------------------------------------------------|
| `id`   | ID of the pipeline.                                |
| `arn`  | ARN of the pipeline.                               |
| `name` | Name of the pipeline.                              |

## Tests

```console
terraform init -backend=false
terraform test
```

The suite in [`tests/`](tests) runs against a mocked AWS provider, so it needs no
credentials and no network. Running it requires Terraform (or OpenTofu) >= 1.7
for `mock_provider`; the module itself still supports >= 1.5.

## License

[MIT](LICENSE)
