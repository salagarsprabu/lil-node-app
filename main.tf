terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6" # which means any version equal & above
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region  = var.region
  # profile = "default" #AWS Credentials Profile (profile = "default") configured on local
  #   access_key = var.aws_access_key
  #   secret_key = var.aws_secret_key
}

data "tls_certificate" "this" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

/* resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com" # URL of the OIDC provider, which is specific to GitHub Actions
  client_id_list  = ["sts.amazonaws.com"] # lists the client IDs that are allowed to authenticate and integrating with AWS Security Token Service.
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint] # thumbprints used to verify the SSL certificate of the OIDC provider
}
*/

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github_actions_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

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
            # Restrict to specific repository and branch
            "token.actions.githubusercontent.com:sub" : "repo:salagarsprabu/lil-node-app:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
