variable "aws_region" {
  description = "Région AWS par défaut pour le provider"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "monthly_limit_usd" {
  description = "Montant maximal mensuel en USD avant alerte"
  type        = number
  default     = 5
}

variable "alert_email" {
  description = "Adresse email recevant les alertes de budget AWS"
  type        = string
}

