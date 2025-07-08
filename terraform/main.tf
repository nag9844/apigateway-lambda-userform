# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_name    = var.project_name
  environment     = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn
  ses_identity_arn   = module.ses.identity_arn
  
  tags = local.common_tags
}

# DynamoDB Module
module "dynamodb" {
  source = "./modules/dynamodb"
  
  project_name = var.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

# SES Module
module "ses" {
  source = "./modules/ses"
  
  project_name     = var.project_name
  environment      = var.environment
  notification_email = var.notification_email
  
  tags = local.common_tags
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"
  
  project_name        = var.project_name
  environment         = var.environment
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.table_name
  notification_email  = var.notification_email
  
  tags = local.common_tags
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"
  
  project_name      = var.project_name
  environment       = var.environment
  lambda_function_arn = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
  
  tags = local.common_tags
}