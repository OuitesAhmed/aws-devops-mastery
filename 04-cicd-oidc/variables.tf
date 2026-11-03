variable "aws_region" {
  description = "Région AWS par défaut"
  type        = string
  default     = "eu-west-3"
}

variable "github_org_or_user" {
  description = "Nom d'utilisateur ou organisation GitHub autorisée à assumer le rôle (ex: votre username GitHub ou '*')"
  type        = string
  default     = "*"
}

variable "github_repo_name" {
  description = "Nom du dépôt GitHub autorisé (ex: aws-devops-mastery ou '*')"
  type        = string
  default     = "*"
}

variable "role_name" {
  description = "Nom du rôle IAM assumé par GitHub Actions"
  type        = string
  default     = "github-actions-deployer-role"
}
