# Dashboard CloudWatch Unifie d'Exploitation (Full-Stack Observability as Code)
resource "aws_cloudwatch_dashboard" "unified" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1 : Titre & Statut Opérationnel
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "## 📊 Unified Cloud Platform Observability\nVue unifiée des métriques critiques : **API Gateway**, **AWS Lambda**, **Amazon DynamoDB** et **Dead-Letter Queue (DLQ)**."
        }
      },

      # Widget 2 : Invocations Lambda & Erreurs
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "order-producer", { stat = "Sum", label = "Producer Invocations", color = "#1f77b4" }],
            ["...", "order-consumer", { stat = "Sum", label = "Consumer Invocations", color = "#2ca02c" }],
            [".", "Errors", "FunctionName", "order-producer", { stat = "Sum", label = "Producer Errors", color = "#d62728" }],
            ["...", "order-consumer", { stat = "Sum", label = "Consumer Errors", color = "#ff7f0e" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "⚡ Lambda Invocations & Execution Errors"
          period  = 300
        }
      },

      # Widget 3 : Durée d'exécution Lambda (p50, p90, p99)
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "order-producer", { stat = "p95", label = "Producer p95 Latency (ms)", color = "#9467bd" }],
            ["...", "order-consumer", { stat = "p95", label = "Consumer p95 Latency (ms)", color = "#8c564b" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "⏱️ Lambda Latency (p95 Percentile)"
          period  = 300
        }
      },

      # Widget 4 : DynamoDB Consumed Capacity & Throttling
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", "orders-table", { stat = "Sum", label = "Consumed Write Units", color = "#17becf" }],
            [".", "ConsumedReadCapacityUnits", ".", ".", { stat = "Sum", label = "Consumed Read Units", color = "#bcbd22" }],
            [".", "ThrottledRequests", ".", ".", { stat = "Sum", label = "Throttled Requests", color = "#d62728" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "💾 Amazon DynamoDB Capacity & Throttling"
          period  = 300
        }
      },

      # Widget 5 : SQS DLQ Messages Non-Traités (Critique)
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "orders-processing-dlq", { stat = "Maximum", label = "DLQ Visible Messages", color = "#e377c2" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "🚨 Dead-Letter Queue (DLQ) Backlog"
          period  = 300
        }
      }
    ]
  })
}

