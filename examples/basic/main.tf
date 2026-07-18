terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region for the provider."
  type        = string
  default     = "us-east-1"
}

variable "pipeline_role_arn" {
  description = "ARN of the CodePipeline service role."
  type        = string
}

variable "artifact_bucket" {
  description = "S3 bucket for pipeline artifacts."
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar connection."
  type        = string
}

provider "aws" {
  region = var.region
}

module "codepipeline" {
  source = "../.."

  name                 = "example-pipeline"
  role_arn             = var.pipeline_role_arn
  artifact_bucket      = var.artifact_bucket
  connection_arn       = var.connection_arn
  source_repository_id = "cybercapybara/example-app"
  build_project_name   = "example-build"

  tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

output "pipeline_arn" {
  value = module.codepipeline.arn
}
