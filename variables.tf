variable "name" {
  description = "Name of the pipeline."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role CodePipeline assumes to run the pipeline."
  type        = string
}

variable "artifact_bucket" {
  description = "Name of the S3 bucket used to store pipeline artifacts."
  type        = string
}

variable "source_repository_id" {
  description = "Full repository identifier for the source stage, for example owner/repo."
  type        = string
}

variable "source_branch" {
  description = "Branch the source stage tracks."
  type        = string
  default     = "main"
}

variable "connection_arn" {
  description = "ARN of the CodeStar connection used to reach the source repository."
  type        = string
}

variable "build_project_name" {
  description = "Name of the CodeBuild project invoked by the build stage."
  type        = string
}

variable "tags" {
  description = "Tags applied to the pipeline."
  type        = map(string)
  default     = {}
}
