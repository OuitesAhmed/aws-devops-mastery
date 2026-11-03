# Fournisseur d'identité OIDC pour GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c5876bd52c77c5f400d32f18387e75e010b9730"
  ]

  tags = {
    Name = "github-actions-oidc-provider"
  }
}

# Rôle IAM assumé temporairement par les runners GitHub Actions (Zero-Secret)
resource "aws_iam_role" "github_actions" {
  name        = var.role_name
  description = "Role IAM utilise par GitHub Actions via OIDC Federation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org_or_user}/${var.github_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = var.role_name
  }
}

# Attachement des permissions de déploiement (AdministratorAccess pour les pipelines IaC)
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
