variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  default = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}