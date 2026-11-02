terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_budgets_budget" "cost_safety_budget" {
  name              = "monthly-cost-safety-guardrail"
  budget_type       = "COST"
  limit_amount      = tostring(var.monthly_limit_usd)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  # Alerte à 80% du budget réel consommé
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alerte à 100% du budget prévu (prévisionnel CloudWatch/AWS Cost Explorer)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}

