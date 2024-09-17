resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.websitegudisa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.websitegudisa.bucket}/*"
      }
    ]
  })
}
