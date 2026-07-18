output "id" {
  description = "ID of the pipeline."
  value       = aws_codepipeline.this.id
}

output "arn" {
  description = "ARN of the pipeline."
  value       = aws_codepipeline.this.arn
}

output "name" {
  description = "Name of the pipeline."
  value       = aws_codepipeline.this.name
}
