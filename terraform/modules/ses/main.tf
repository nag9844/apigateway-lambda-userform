# SES configuration for email-only setup (no domain required)

resource "aws_ses_email_identity" "sender_email" {
  email = var.notification_email
}

# Only create domain identity if it's actually a domain (not an email)
resource "aws_ses_domain_identity" "domain" {
  count  = can(regex("^[^@]+\\.[^@]+$", var.domain)) ? 1 : 0
  domain = var.domain
}

resource "aws_ses_domain_dkim" "domain" {
  count  = can(regex("^[^@]+\\.[^@]+$", var.domain)) ? 1 : 0
  domain = aws_ses_domain_identity.domain[0].domain
}

# SES configuration set
resource "aws_ses_configuration_set" "contact_form" {
  name = "contact-form-config"

  delivery_options {
    tls_policy = "Require"
  }
}