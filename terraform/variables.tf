variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "contact-form-handler"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "contact-form-submissions"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "contact-form-api"
}

variable "ses_domain" {
  description = "Domain for SES (must be verified)"
  type        = string
  default     = "example.com"
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "contact@example.com"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "contact-form-api"
    Environment = "production"
  }
}