output "domain_identity" {
  description = "SES domain identity"
  value       = aws_ses_domain_identity.domain.domain
}

output "domain_verification_token" {
  description = "Domain verification token"
  value       = aws_ses_domain_identity.domain.verification_token
}

output "dkim_tokens" {
  description = "DKIM tokens for domain verification"
  value       = aws_ses_domain_dkim.domain.dkim_tokens
}