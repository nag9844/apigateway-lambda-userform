terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM module
module "iam" {
  source = "./modules/iam"
  
  lambda_function_name = var.lambda_function_name
  dynamodb_table_name  = var.dynamodb_table_name
  ses_domain          = var.ses_domain
}

# DynamoDB module
module "dynamodb" {
  source = "./modules/dynamodb"
  
  table_name = var.dynamodb_table_name
  tags       = var.tags
}

# SES module
module "ses" {
  source = "./modules/ses"
  
  domain           = var.ses_domain
  notification_email = var.notification_email
  tags             = var.tags
}

# Lambda module
module "lambda" {
  source = "./modules/lambda"
  
  function_name        = var.lambda_function_name
  lambda_role_arn      = module.iam.lambda_role_arn
  dynamodb_table_name  = var.dynamodb_table_name
  ses_source_email     = var.notification_email
  tags                 = var.tags
}

# API Gateway module
module "api_gateway" {
  source = "./modules/api-gateway"
  
  api_name                    = var.api_name
  lambda_function_arn         = module.lambda.lambda_function_arn
  lambda_function_invoke_arn  = module.lambda.lambda_function_invoke_arn
  lambda_function_name        = var.lambda_function_name
  tags                        = var.tags
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}