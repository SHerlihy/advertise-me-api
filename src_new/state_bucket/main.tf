terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "sherlihydtcom"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket_prefix = "state-bucket-"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "name" {
  value = aws_s3_bucket.state_bucket.id
}
