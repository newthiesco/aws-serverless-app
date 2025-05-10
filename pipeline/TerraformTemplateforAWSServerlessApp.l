# Terraform Template for AWS Serverless Application

This Terraform configuration sets up the following AWS resources:

- S3 Bucket for static website hosting
- CloudFront distribution for CDN
- API Gateway for REST endpoints
- Lambda function written in Python
- DynamoDB table for backend storage
- Route 53 configuration for custom domain
- Archive packaging of Lambda source code

## File Structure

```
aws-serverless-app/
├── main.tf
├── variables.tf
├── outputs.tf
├── lambda_function/
│   └── lambda_function.py
```

---

## `lambda_function/lambda_function.py`
```python
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
```

---

## `main.tf`
```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "static_site" {
  bucket = var.s3_bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "app_data" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "api_handler" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.9"
  filename      = archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(archive_file.lambda_zip.output_path)
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_handler.invoke_arn
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_site.website_endpoint
    origin_id   = "s3-static-site"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-static-site"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "cdn_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
```

---

## `variables.tf`
```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for static website"
}

variable "lambda_function_name" {
  default = "serverless-api-handler"
}

variable "dynamodb_table_name" {
  default = "app-data-table"
}

variable "domain_name" {
  description = "Your custom domain name"
}
```

---

## `outputs.tf`
```hcl
output "s3_website_url" {
  value = aws_s3_bucket.static_site.website_endpoint
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
```

---

Let me know if you want a `Makefile`, `build.sh`, or GitHub Actions CI/CD workflow to deploy this!
