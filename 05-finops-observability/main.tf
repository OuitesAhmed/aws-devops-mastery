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

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "AWS-DevOps-Mastery"
      ManagedBy   = "Terraform"
      Module      = "Observability-and-FinOps"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

