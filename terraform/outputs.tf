output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.api_gateway.api_url
}

output "api_gateway_stage_url" {
  description = "URL of the API Gateway stage"
  value       = module.api_gateway.stage_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.table_arn
}

output "ses_identity_arn" {
  description = "ARN of the SES identity"
  value       = module.ses.identity_arn
}

output "ses_configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = module.ses.configuration_set_name
}

output "iam_lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.iam.lambda_role_arn
}

# Output for frontend environment variable
output "frontend_api_endpoint" {
  description = "API endpoint for frontend configuration"
  value       = "${module.api_gateway.stage_url}/contact"
}