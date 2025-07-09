resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "domain" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_ses_email_identity" "notification_email" {
  email = var.notification_email
}

# SES configuration set
resource "aws_ses_configuration_set" "contact_form" {
  name = "contact-form-config"

  delivery_options {
    tls_policy = "Require"
  }
}