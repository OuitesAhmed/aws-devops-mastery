variable "aws_region" {
  description = "Région AWS principale pour le déploiement"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "environment" {
  description = "Environnement cible (ex: audit, security, prod)"
  type        = string
  default     = "security"
}

variable "cloudtrail_name" {
  description = "Nom de la piste d'audit CloudTrail"
  type        = string
  default     = "org-security-audit-trail"
}

variable "enable_guardduty" {
  description = "Activer Amazon GuardDuty pour la détection de menaces"
  type        = bool
  default     = true
}

