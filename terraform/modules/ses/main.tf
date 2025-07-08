# SES email identity
resource "aws_ses_email_identity" "notification_email" {
  email = var.notification_email

  tags = var.tags
}

# SES configuration set
resource "aws_ses_configuration_set" "contact_form" {
  name = "${var.project_name}-${var.environment}-config-set"

  delivery_options {
    tls_policy = "Require"
  }

  tags = var.tags
}

# SES event destination for tracking
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.contact_form.name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "MessageTag"
    value_source   = "messageTag"
  }
}

# SES domain identity (optional - for custom domain)
# Uncomment if you want to use a custom domain
# resource "aws_ses_domain_identity" "domain" {
#   domain = var.domain_name
# }

# SES domain DKIM (optional - for custom domain)
# resource "aws_ses_domain_dkim" "domain_dkim" {
#   domain = aws_ses_domain_identity.domain.domain
# }