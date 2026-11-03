variable "aws_region" {
  description = "Région AWS pour le déploiement réseau et compute"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "environment" {
  description = "Nom de l'environnement (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "Bloc CIDR pour le Virtual Private Cloud"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Activer un NAT Gateway payant (~32$/mois). Désactivé par défaut pour le mode 0,00$ FinOps"
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Image Docker à exécuter dans les tâches ECS Fargate"
  type        = string
  default     = "public.ecr.aws/docker/library/httpd:alpine"
}

variable "container_port" {
  description = "Port d'écoute du conteneur"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Nombre de tâches Fargate à exécuter"
  type        = number
  default     = 1
}

