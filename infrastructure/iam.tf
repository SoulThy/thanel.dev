resource "aws_iam_policy" "blog_deploy" {
  name        = "${var.project_name}-deploy-policy"
  description = "This policy enables access to the S3 of my personal blog and enables sending invalidate cache cloudfront requests"

  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket",
          ]
          Effect = "Allow"
          Resource = [
            aws_s3_bucket.blog.arn,
            "${aws_s3_bucket.blog.arn}/*",
          ]
          Sid = "S3DeployAccess"
        },
        {
          Action   = ["cloudfront:CreateInvalidation"]
          Effect   = "Allow"
          Resource = aws_cloudfront_distribution.blog.arn
          Sid      = "CloudFrontInvalidation"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "${var.project_name}-github-actions-deploy-role"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }
            StringLike = {
              "token.actions.githubusercontent.com:sub" = "${var.github_oidc_subject_claim_prefix}:ref:refs/heads/${var.github_branch}"
            }
          }
          Effect = "Allow"
          Principal = {
            Federated = aws_iam_openid_connect_provider.github.arn
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.blog_deploy.arn
}
