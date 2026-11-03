# Topic SNS pour le dispatch des alertes opérationnelles (Email, Slack, PagerDuty)
resource "aws_sns_topic" "alerts" {
  name = "platform-critical-alerts-topic"

  tags = {
    Name = "platform-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 1. Alarme : Erreurs d'exécution Lambda (Producer ou Consumer)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-execution-errors-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alerte si au moins une erreur d'execution survient sur une fonction Lambda"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "order-consumer"
  }
}

# 2. Alarme : Détection de messages dans la Dead-Letter Queue (DLQ)
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "sqs-dlq-messages-detected-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alerte critique : au moins un message non traitable a atterri dans la DLQ"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = "orders-processing-dlq"
  }
}

# 3. Alarme : Taux d'erreurs 5XX sur l'API Gateway
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "api-gateway-5xx-errors-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xx"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 2
  alarm_description   = "Alerte si l'API Gateway retourne plusieurs erreurs 5XX serveur"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"
}
