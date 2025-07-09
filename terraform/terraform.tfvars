aws_region           = "ap-south-1"
lambda_function_name = "contact-form-handler"
dynamodb_table_name  = "contact-form-submissions"
api_name             = "contact-form-api"

# Must be a verified domain in SES
ses_domain = "gmail.com"

# Must be a verified email in SES
notification_email = "vnagaraj984@gmail.com"

tags = {
  Project     = "contact-form-api"
  Environment = "production"
  Owner       = "devops"
}