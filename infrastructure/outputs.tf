output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_deploy.arn
  description = "The IAM role ARN to pass to role-to-assume in GitHub Actions."
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.blog.id
  description = "The S3 bucket name to pass to BUCKET_NAME in GitHub Actions."
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.blog.id
  description = "The CloudFront distribution ID to pass to DISTRIBUTION_ID in GitHub Actions."
}
