output "bucket_name" {
    value = aws_s3_bucket.fake_docs.arn
}

output "bucket_access_policy" {
    value = aws_iam_policy.dev_gateway_access.arn
}
