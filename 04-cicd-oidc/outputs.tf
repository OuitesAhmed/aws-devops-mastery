output "github_oidc_provider_arn" {
  description = "ARN du fournisseur d'identite OIDC GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN du role IAM a renseigner dans vos workflows GitHub Actions (role-to-assume)"
  value       = aws_iam_role.github_actions.arn
}
