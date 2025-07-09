output "email_identity" {
  description = "SES email identity"
  value       = aws_ses_email_identity.sender_email.email
}

output "domain_identity" {
  description = "SES domain identity (if domain is used)"
  value       = length(aws_ses_domain_identity.domain) > 0 ? aws_ses_domain_identity.domain[0].domain : null
}

output "domain_verification_token" {
  description = "Domain verification token (if domain is used)"
  value       = length(aws_ses_domain_identity.domain) > 0 ? aws_ses_domain_identity.domain[0].verification_token : null
}

output "dkim_tokens" {
  description = "DKIM tokens for domain verification (if domain is used)"
  value       = length(aws_ses_domain_dkim.domain) > 0 ? aws_ses_domain_dkim.domain[0].dkim_tokens : []
}