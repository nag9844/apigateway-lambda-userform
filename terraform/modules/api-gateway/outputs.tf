output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "https://${aws_api_gateway_rest_api.contact_form_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/contact"
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.contact_form_api.id
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.contact_form_api.execution_arn
}