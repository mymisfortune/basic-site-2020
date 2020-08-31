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

resource "aws_s3_bucket_object" "doc" {
  bucket                 = aws_s3_bucket.static_content.bucket
  key                    = "index.html"
  source                 = "./content/index.html"
  content_type           = "text/html; charset=utf-8"
  etag                   = filemd5("./content/index.html")
  server_side_encryption = "AES256"

  # Upload the default doc if it doesn't exist, then ignore any further changes so it can be updated elsewhere.
  lifecycle {
    ignore_changes = [source, etag]
  }
}

resource "aws_s3_bucket_object" "image" {
  bucket                 = aws_s3_bucket.static_content.bucket
  key                    = "img/hello_world.jpg"
  source                 = "./content/img/hello_world.jpg"
  content_type           = "text/html; charset=utf-8"
  etag                   = filemd5("./content/img/hello_world.jpg")
  server_side_encryption = "AES256"
}
