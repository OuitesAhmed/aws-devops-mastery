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
      Module      = "Network-and-ECS"
    }
  }
}

# Récupération dynamique des zones de disponibilité (AZ) disponibles dans la région
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

