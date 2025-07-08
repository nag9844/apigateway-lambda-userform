output "identity_arn" {
  description = "ARN of the SES email identity"
  value       = aws_ses_email_identity.notification_email.arn
}

output "configuration_set_name" {
  description = "Name of the SES configuration set"
  value       = aws_ses_configuration_set.contact_form.name
}

output "configuration_set_arn" {
  description = "ARN of the SES configuration set"
  value       = aws_ses_configuration_set.contact_form.arn
}