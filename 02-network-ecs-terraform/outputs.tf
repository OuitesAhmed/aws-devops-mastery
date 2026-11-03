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

