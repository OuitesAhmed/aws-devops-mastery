output "vpc_id" {
  description = "ID du Virtual Private Cloud créé"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs des subnets publics (ALB & Ingress)"
  value       = aws_subnet.public[*].id
}

output "private_app_subnets" {
  description = "IDs des subnets privés applicatifs"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnets" {
  description = "IDs des subnets privés base de données"
  value       = aws_subnet.private_db[*].id
}

output "alb_dns_name" {
  description = "URL publique de l'Application Load Balancer (Accès Web direct)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nom du service ECS Fargate"
  value       = aws_ecs_service.app.name
}

# ==============================================================================
# Outputs AWS Secrets Manager & Aurora Serverless v2
# ==============================================================================

output "app_secret_arn" {
  description = "ARN du secret applicatif géré dans AWS Secrets Manager"
  value       = aws_secretsmanager_secret.app_config.arn
}

output "aurora_cluster_endpoint" {
  description = "Endpoint d'écriture du cluster Aurora Serverless v2 (si activé)"
  value       = try(aws_rds_cluster.aurora[0].endpoint, "Désactivé (enable_database = false)")
}

output "aurora_cluster_reader_endpoint" {
  description = "Endpoint de lecture (Read Replica) du cluster Aurora Serverless v2 (si activé)"
  value       = try(aws_rds_cluster.aurora[0].reader_endpoint, "Désactivé (enable_database = false)")
}

output "aurora_master_secret_arn" {
  description = "ARN du secret contenant les identifiants maîtres Aurora généré et géré par AWS Secrets Manager"
  value       = try(aws_rds_cluster.aurora[0].master_user_secret[0].secret_arn, "Désactivé (enable_database = false)")
}


