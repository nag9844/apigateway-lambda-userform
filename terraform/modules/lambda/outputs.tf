output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.contact_form_handler.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.contact_form_handler.function_name
}

output "lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.contact_form_handler.invoke_arn
}