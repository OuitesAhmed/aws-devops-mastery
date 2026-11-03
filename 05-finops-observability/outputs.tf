output "dashboard_name" {
  description = "Nom du tableau de bord CloudWatch"
  value       = aws_cloudwatch_dashboard.unified.dashboard_name
}

output "dashboard_url" {
  description = "URL directe pour consulter le tableau de bord dans la console AWS"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards/dashboard/${var.dashboard_name}"
}

output "alerts_topic_arn" {
  description = "ARN du topic SNS pour les notifications d'alarmes"
  value       = aws_sns_topic.alerts.arn
}

