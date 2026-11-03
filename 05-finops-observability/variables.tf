variable "aws_region" {
  description = "Région AWS pour l'observabilité"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environnement cible pour les métriques"
  type        = string
  default     = "prod"
}

variable "dashboard_name" {
  description = "Nom du tableau de bord CloudWatch unifié"
  type        = string
  default     = "Platform-Unified-Observability"
}

variable "alert_email" {
  description = "Adresse email recevant les alarmes CloudWatch"
  type        = string
  default     = "alerts-ops@example.com"
}

