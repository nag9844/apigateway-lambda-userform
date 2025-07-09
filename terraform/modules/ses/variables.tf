variable "domain" {
  description = "Domain for SES"
  type        = string
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to SES resources"
  type        = map(string)
  default     = {}
}