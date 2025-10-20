resource "aws_s3_bucket" "frontend_s3_bucket" {
   bucket = var.frontend_s3_bucket

   tags = {
        name = "Frontend S3_bucket"
        Environment = "Dev"
   }
}

resource "aws_s3_object" "frontend_index_file" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id
  key = "index.html"
  source = "Frontend/index.html"
  etag = filemd5("Frontend/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "frontend_style_file" {
   bucket = aws_s3_bucket.frontend_s3_bucket.id
   key = "style.css"
   source = "Frontend/style.css"
   etag = filemd5("Frontend/style.css") 
   content_type = "text/css"
}

resource "aws_s3_object" "frontend_script_file" {
   bucket = aws_s3_bucket.frontend_s3_bucket.id
   key = "script.js"
   source = "Frontend/script.js"
   etag = filemd5("Frontend/script.js") 
   content_type = "application/javascript"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
   bucket = aws_s3_bucket.frontend_s3_bucket.id

   policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
         {
            Sid = "AllowCloudFrontToSeeBucketContent"
            Effect = "Allow"
            Principal = {
               CanonicalUser = aws_cloudfront_origin_access_identity.cloudfront_OAI.s3_canonical_user_id
            }

            Action = "s3:GetObject"
            Resource = "${aws_s3_bucket.frontend_s3_bucket.arn}/*"
         }
      ]   
   })      
}

resource "aws_s3_bucket" "Lambda_backend_zip" {
   bucket = var.lambda_backend_zip

   tags = {
      name = "lambda backend zip bucket"
      Environment = "Dev"
   }
}

resource "aws_s3_object" "lambda_zip_file" {
  bucket = aws_s3_bucket.Lambda_backend_zip.id
  source = "lambda.zip"
  key = "lambda.zip"
  etag = filemd5("lambda.zip")
}
