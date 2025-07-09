output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/contact"
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.contact_form_api.id
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.contact_form_api.execution_arn
}

output "api_key" {
  description = "API Gateway API key"
  value       = aws_api_gateway_api_key.contact_form_key.value
  sensitive   = true
}