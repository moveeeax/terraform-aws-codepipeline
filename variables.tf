variable "name" {
  description = "Name of the pipeline."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.@_-]{1,100}$", var.name))
    error_message = "The name must be 1-100 characters and may only contain letters, digits, and the characters . @ _ -."
  }
}

variable "role_arn" {
  description = "ARN of the IAM role CodePipeline assumes to run the pipeline."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:role/.+$", var.role_arn))
    error_message = "The role_arn must be an IAM role ARN, for example arn:aws:iam::123456789012:role/my-pipeline-role."
  }
}

variable "artifact_bucket" {
  description = "Name of the S3 bucket used to store pipeline artifacts."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.artifact_bucket))
    error_message = "The artifact_bucket must be an S3 bucket name (3-63 lowercase characters), not an ARN or a URL."
  }
}

variable "artifact_encryption_key_id" {
  description = <<-EOT
    KMS key used to encrypt the pipeline artifact store, given as a key ARN, key ID, or
    alias. When null, CodePipeline falls back to the AWS managed key for S3.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.artifact_encryption_key_id == null || can(regex(
      "^(arn:aws[a-zA-Z-]*:kms:[a-z0-9-]+:[0-9]{12}:(key|alias)/.+|alias/.+|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$",
      coalesce(var.artifact_encryption_key_id, "alias/unset")
    ))
    error_message = "The artifact_encryption_key_id must be a KMS key ARN, a key ID (UUID, e.g. 1234abcd-12ab-34cd-56ef-1234567890ab), or alias/<name>."
  }
}

variable "source_repository_id" {
  description = "Full repository identifier for the source stage, for example owner/repo."
  type        = string

  validation {
    condition     = can(regex("^[^/[:space:]]+/[^/[:space:]]+$", var.source_repository_id))
    error_message = "The source_repository_id must be a full repository identifier in owner/repo form."
  }
}

variable "source_branch" {
  description = "Branch the source stage tracks."
  type        = string
  default     = "main"

  validation {
    condition     = length(trimspace(var.source_branch)) > 0
    error_message = "The source_branch must not be empty."
  }
}

variable "connection_arn" {
  description = "ARN of the CodeStar connection used to reach the source repository."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:(codestar-connections|codeconnections):[a-z0-9-]+:[0-9]{12}:connection/.+$", var.connection_arn))
    error_message = "The connection_arn must be a CodeConnections (or legacy CodeStar Connections) connection ARN."
  }
}

variable "build_project_name" {
  description = "Name of the CodeBuild project invoked by the build stage."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_-]{1,254}$", var.build_project_name))
    error_message = "The build_project_name must be a CodeBuild project name (2-255 characters, letters, digits, _ and -)."
  }
}

variable "tags" {
  description = "Tags applied to the pipeline."
  type        = map(string)
  default     = {}
}
