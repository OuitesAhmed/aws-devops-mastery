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

# ==============================================================================
# Variables Aurora Serverless v2 PostgreSQL & Base de Données
# ==============================================================================

variable "enable_database" {
  description = "Activer Amazon Aurora Serverless v2. Désactivé par défaut (false) pour garantir un coût à 0,00$ FinOps en phase de repos."
  type        = bool
  default     = false
}

variable "aurora_engine_version" {
  description = "Version du moteur PostgreSQL pour Aurora Serverless v2"
  type        = string
  default     = "16.8"
}

variable "aurora_min_capacity" {
  description = "Capacité minimale en ACU (Aurora Capacity Units). 0.5 ACU = ~1 Go RAM"
  type        = number
  default     = 0.5
}

variable "aurora_max_capacity" {
  description = "Capacité maximale en ACU. 1.0 ACU = ~2 Go RAM"
  type        = number
  default     = 1.0
}

variable "db_name" {
  description = "Nom initial de la base de données PostgreSQL"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Nom d'utilisateur administrateur de la base de données"
  type        = string
  default     = "dbadmin"
}


