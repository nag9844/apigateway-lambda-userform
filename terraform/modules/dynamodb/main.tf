# DynamoDB table for storing contact form submissions
resource "aws_dynamodb_table" "contact_submissions" {
  name           = "${var.project_name}-${var.environment}-submissions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  # Global Secondary Index for querying by email
  global_secondary_index {
    name     = "email-index"
    hash_key = "email"
    projection_type = "ALL"
  }

  # Global Secondary Index for querying by date
  global_secondary_index {
    name     = "created-at-index"
    hash_key = "created_at"
    projection_type = "ALL"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-submissions"
  })
}