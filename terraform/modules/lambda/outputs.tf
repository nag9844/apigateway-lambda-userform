output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.contact_form_handler.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.contact_form_handler.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.contact_form_handler.invoke_arn
}