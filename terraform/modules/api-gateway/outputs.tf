output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.contact_form_api.id
}

output "api_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_rest_api.contact_form_api.execution_arn
}

output "stage_url" {
  description = "URL of the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.contact_form_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.contact_form_stage.stage_name}"
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.contact_form_stage.stage_name
}

# Data source for current region
data "aws_region" "current" {}