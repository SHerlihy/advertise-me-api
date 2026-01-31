terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
    profile = "kbaas"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "fake_docs" {
  bucket_prefix = "fakedocs"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "fake_docs" {
  bucket = aws_s3_bucket.fake_docs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# adding here as want to couple iam permissions close to resource
resource "aws_iam_policy" "dev_gateway_access" {
  name        = "DevGatewayS3Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.fake_docs.arn,
          "${aws_s3_bucket.fake_docs.arn}/*",
        ],
      },
    ],
  })
}
