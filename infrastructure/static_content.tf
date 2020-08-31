resource "aws_s3_bucket" "static_content" {
  bucket = "basic-site-2020-prod.mymisfortune.com"
  acl    = "private"

  tags = {
    Name        = "static_content"
    Environment = "prod"
  }
}

data "aws_iam_policy_document" "static_content_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_content.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.site.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_content" {
  bucket = aws_s3_bucket.static_content.id
  policy = data.aws_iam_policy_document.static_content_access.json
}
