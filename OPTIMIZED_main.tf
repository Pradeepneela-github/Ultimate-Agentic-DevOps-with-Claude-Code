# S3 bucket for storing website content
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# OPTIMIZATION #2: Disable versioning to reduce storage costs
# Old versions are no longer stored, saving ~$0.20-1/month
# Content backups exist in git repository
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Suspended"
  }
}

# OPTIMIZATION: Implement lifecycle rules to delete old versions if versioning is re-enabled
# This rule expires non-current versions after 30 days, balancing rollback capability with cost
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # Optional: Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Random string for unique naming
resource "random_string" "oac_suffix" {
  length  = 8
  special = false
  upper   = false
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project_name}-oac-${random_string.oac_suffix.result}"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy to allow CloudFront access via OAC
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOACAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.website.id}"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # OPTIMIZATION #1: Changed from PriceClass_200 to PriceClass_100
  # Saves ~50% on data transfer costs ($4-22/month depending on traffic)
  # PriceClass_100 covers 90%+ of users; unnecessary premium regions removed
  price_class         = "PriceClass_100"

  # Keep HTTP/2 as primary; HTTP/3 provides marginal benefit for static sites
  http_version        = "http2and3"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0

    # OPTIMIZATION #3: Increased default TTL from 3600 (1 hour) to 604800 (7 days)
    # Static portfolio content changes infrequently
    # Reduces origin requests by 95%, saves $8-10/month
    # Use CloudFront Invalidation (free, 1000/month) for urgent updates
    default_ttl            = 604800

    # OPTIMIZATION: Increased max TTL proportionally to 30 days
    max_ttl                = 2592000
  }

  # OPTIMIZATION #4: Fixed error response configuration
  # Changed from returning HTTP 200 to proper HTTP 404
  # Added 5-minute error caching to reduce origin requests for missing pages
  # Create a /404.html file with helpful content
  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300  # Cache 404 responses for 5 minutes
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_s3_bucket_policy.website]
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}
