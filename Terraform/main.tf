terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = var.region
}

# Fetch the OIDC certificate for GitHub Actions
data "tls_certificate" "this" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create OIDC Provider for GitHub Actions in AWS
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
}

# Create IAM Role for GitHub Actions to assume
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsOIDCRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:salagarsprabu/lil-node-app:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Attach S3 Full Access policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Output the ARN of the GitHub Actions role
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
