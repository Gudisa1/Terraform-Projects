# Specify the AWS provider and region
provider "aws" {
  region = var.region
}

# S3 bucket creation
resource "aws_s3_bucket" "websitegudisa" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
    Environment = "Dev"
  }

}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.websitegudisa.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket ACL to make the bucket publicly readable
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.websitegudisa.id
  acl    = "public-read"
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.websitegudisa.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "gudisa_versioning" {
  bucket = aws_s3_bucket.websitegudisa.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "websitegudisa" {
  bucket = aws_s3_bucket.websitegudisa.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}


locals {
  files = {
    "index.html" = "index.html",
    "styles.css" = "styles.css"
  }
}

# Upload files to the bucket using a loop
resource "aws_s3_object" "files" {
  for_each = local.files

  bucket       = aws_s3_bucket.websitegudisa.id
  key          = each.key
  source       = each.value
  acl          = "public-read"
  content_type = lookup({
    "index.html" = "text/html",
    "styles.css" = "text/css"
  }, each.key, "application/octet-stream")
}


# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.websitegudisa.bucket
}

# Output the website URL
output "website_url" {
  description = "The URL of the static website hosted in the S3 bucket."
  value       = "http://${aws_s3_bucket.websitegudisa.bucket}.s3-website-${var.region}.amazonaws.com"
}
