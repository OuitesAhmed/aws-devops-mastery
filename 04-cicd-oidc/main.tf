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
      Environment = "shared"
      Project     = "AWS-DevOps-Mastery"
      ManagedBy   = "Terraform"
      Module      = "CI-CD-OIDC"
    }
  }
}

data "aws_caller_identity" "current" {}

