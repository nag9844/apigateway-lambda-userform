# API Gateway REST API
resource "aws_api_gateway_rest_api" "contact_form_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API for contact form submissions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# API Gateway Resource
resource "aws_api_gateway_resource" "contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  parent_id   = aws_api_gateway_rest_api.contact_form_api.root_resource_id
  path_part   = "contact"
}

# API Gateway Method - POST
resource "aws_api_gateway_method" "contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method - OPTIONS (for CORS)
resource "aws_api_gateway_method" "contact_options" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Integration - POST
resource "aws_api_gateway_integration" "contact_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_function_arn
}

# API Gateway Integration - OPTIONS (for CORS)
resource "aws_api_gateway_integration" "contact_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# API Gateway Method Response - POST
resource "aws_api_gateway_method_response" "contact_post_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_post.http_method
  status_code = "200"

  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# API Gateway Method Response - OPTIONS
resource "aws_api_gateway_method_response" "contact_options_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

# API Gateway Integration Response - OPTIONS
resource "aws_api_gateway_integration_response" "contact_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = aws_api_gateway_method_response.contact_options_response.status_code

  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
  }


  depends_on = [aws_api_gateway_integration.contact_options_integration]
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_form_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "contact_form_deployment" {
  depends_on = [
    aws_api_gateway_integration.contact_post_integration,
    aws_api_gateway_integration.contact_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact_resource.id,
      aws_api_gateway_method.contact_post.id,
      aws_api_gateway_method.contact_options.id,
      aws_api_gateway_integration.contact_post_integration.id,
      aws_api_gateway_integration.contact_options_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "contact_form_stage" {
  deployment_id = aws_api_gateway_deployment.contact_form_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  stage_name    = "prod"

  tags = var.tags
}