output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.contact_submissions.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.contact_submissions.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.contact_submissions.id
}