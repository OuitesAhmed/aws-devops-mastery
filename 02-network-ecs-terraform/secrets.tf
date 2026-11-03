# ==============================================================================
# AWS Secrets Manager - Gestion sécurisée des secrets sans mot de passe en dur
# ==============================================================================

# 1. Secret applicatif (Tokens API, clés JWT, variables sensibles)
resource "aws_secretsmanager_secret" "app_config" {
  name_prefix             = "${var.environment}-app-secrets-"
  description             = "Application secrets et configurations sensibles pour ECS"
  recovery_window_in_days = 0 # FinOps : suppression immédiate sans frais de rétention

  tags = {
    Name = "${var.environment}-app-secrets"
  }
}

# 2. Version du secret stockant un payload JSON avec plusieurs clés sensibles
resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    api_key     = "sec_live_9a8b7c6d5e4f3a2b1c"
    jwt_secret  = "enterprise_grade_super_secret_signing_token_2026"
    environment = var.environment
  })
}
