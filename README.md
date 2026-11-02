# AWS DevOps & Freelance Mastery Repository

Ce dépôt regroupe l'ensemble des modules d'infrastructure, architectures de référence et projets concrets réalisés selon les standards d'entreprise et du marché freelance.

## 🗂️ Structure du projet

```
aws-devops-mastery/
├── Makefile                          # Commandes rapides (lint, test, plan, apply)
├── 00-prerequisites/                 # Scripts d'installation des outils & vérifications
├── 01-landing-zone-terraform/        # Projet 1 : Baseline sécurité, SCPs, IAM & Audit
├── 02-network-ecs-terraform/         # Projet 2 : VPC 3-tiers, ECS Fargate, Aurora, ALB
├── 03-serverless-cdk/                # Projet 3 : AWS CDK (TypeScript/Python), API, EventBridge
├── 04-cicd-oidc/                     # Projet 4 : GitHub Actions OIDC sans clés API & Blue/Green
└── 05-finops-observability/          # Projet 5 : CloudWatch dashboards, alertes Slack, audit FinOps
```

## 🛠️ Stack Technique

- **Cloud Provider** : Amazon Web Services (AWS)
- **Infrastructure as Code** : Terraform / OpenTofu + AWS CDK
- **Conteneurs & Orchestration** : Docker, Amazon ECR, Amazon ECS (Fargate)
- **Serverless** : AWS Lambda, API Gateway, DynamoDB, Amazon EventBridge
- **CI/CD & Sécurité** : GitHub Actions (IAM OIDC Federation), Trivy, TFLint, cdk-nag
- **Observabilité & FinOps** : Amazon CloudWatch, Infracost

