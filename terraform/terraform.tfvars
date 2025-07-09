# Configuration for Gmail-only SES setup

aws_region           = "ap-south-1"
lambda_function_name = "contact-form-handler"
dynamodb_table_name  = "contact-form-submissions"
api_name             = "contact-form-api"

# Use your Gmail address for both domain and notification
# This tells SES to use email identity instead of domain identity
ses_domain = "vnagaraj984@gmail.com"

# Your Gmail address where you want to receive notifications
notification_email = "vnagaraj984@gmail.com"

tags = {
  Project     = "contact-form-api"
  Environment = "production"
  Owner       = "devops"
}