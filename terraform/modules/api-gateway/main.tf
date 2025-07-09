# Data source for current region
data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "contact_form_api" {
  name        = var.api_name
  description = "API for contact form submissions"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = var.tags
}

resource "aws_api_gateway_resource" "contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  parent_id   = aws_api_gateway_rest_api.contact_form_api.root_resource_id
  path_part   = "contact"
}

# OPTIONS method for CORS
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# POST method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "post_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration
  ]
  
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
}

# Stage for the deployment
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  stage_name    = "prod"
  
  tags = var.tags
}