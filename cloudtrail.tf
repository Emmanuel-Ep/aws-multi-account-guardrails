# ---------- LOOK-UPS (read only, build nothing) ----------

# "Who am I?" Reads the account number I'm logged into (...7185)
data "aws_caller_identity" "current" {}

# "Which organisation am I in?" Reads the org ID (o-6g9344pa64)
data "aws_organizations_organization" "current" {}

# ---------- THE VAULT ----------

# The S3 bucket that will hold every account's CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "guardrails-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# Fitting 1: block ALL public access
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Fitting 2: versioning, so overwritten or deleted logs keep their old copies
resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Fitting 3: encrypt everything stored in the vault
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

locals {
  trail_name = "org-trail"
  trail_arn = "arn:aws:cloudtrail:ap-southeast-2:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = templatefile("${path.module}/policies/cloudtrail-bucket-policy.json", {
    bucket_arn = aws_s3_bucket.cloudtrail_logs.arn
    trail_arn = local.trail_arn
    account_id = data.aws_caller_identity.current.account_id
    org_id = data.aws_organizations_organization.current.id

  }
  )
}

resource "aws_cloudtrail" "my_trail" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]

  name = local.trail_name
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_organization_trail = true
  is_multi_region_trail = true
  enable_log_file_validation = true

}
