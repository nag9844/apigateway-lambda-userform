variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "ses_domain" {
  description = "SES domain"
  type        = string
}

variable "notification_email" {
  description = "Notification email address"
  type        = string
}