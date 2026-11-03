# 🚀 AWS Cloud DevOps Mastery — Portfolio & Architecture Hub

Ce dépôt contient l'ensemble des architectures de référence, configurations d'Infrastructure as Code (IaC) et pipelines CI/CD conçus et déployés sur **Amazon Web Services (AWS)** selon les standards de sécurité d'entreprise (**CIS AWS Foundations Benchmark**) et le cadre **AWS Well-Architected Framework**.

---

## 🏛️ Matrice des Projets Réalisés

| Projet | Titre & Cas d'Usage | Stack Technique | Livrables & Preuves |
|---|---|---|---|
| **00** | **Garde-Fou Financier (FinOps Guardrail)** | Terraform, AWS Budgets | Alarme email automatisée dès 80% (4$) et 100% (5$) de prévisionnel. |
| **01** | **Enterprise Security Baseline & Audit** | Terraform, CloudTrail, GuardDuty, S3, IAM | Piste d'audit multi-région chiffrée, validation SHA-256, S3 Public Block global, conformité SCP. |
| **02** | **Réseau 3-Tiers & Compute Conteneurisé** | Terraform, VPC, ALB, ECS Fargate, Docker | VPC Multi-AZ (6 subnets), Security Groups Zero-Trust chaînés, cluster ECS Fargate avec ALB testé à 200 OK. |
| **03** | **Architecture Serverless Event-Driven (EDA)** | AWS CDK (TypeScript), API GW, EventBridge, Lambda Graviton, SQS DLQ, DynamoDB | Ingestion synchrone HTTP POST, routage asynchrone EventBridge, tests unitaires Jest d'infra, table DynamoDB NoSQL. |
| **04** | **CI/CD GitOps Zero-Secret** | AWS IAM OIDC Federation, GitHub Actions | Authentification par jetons JWT éphémères sans aucune clé API permanente stockée dans GitHub. |
| **05** | **Observabilité & Audit FinOps** | CloudWatch Dashboards & Alarms, Python Boto3, SNS | Tableau de bord unifié as code, alarmes métriques (Erreurs Lambda & DLQ), script d'audit des coûts orphelins. |

---

## 🛠️ Double Compétence IaC Validée

* **Terraform (HCL)** : Utilisé pour les couches d'infrastructure transverses et de sécurité (Landing Zone, VPC, Security Groups, OIDC, Dashboards CloudWatch).
* **AWS CDK (TypeScript)** : Utilisé pour l'application Cloud Native événementielle avec Constructs L2/L3, bundling esbuild automatique et tests unitaires d'assertions.

---

## 📊 Tableau de Bord CloudWatch Unifié

Le Dashboard CloudWatch déployé dans le Projet 5 est consultable directement via la console AWS :
👉 **[Accéder au CloudWatch Dashboard](https://eu-west-3.console.aws.amazon.com/cloudwatch/home?region=eu-west-3#dashboards/dashboard/Platform-Unified-Observability)**

---

## 🐍 Exécution de l'Audit FinOps Local

```bash
cd 05-finops-observability/scripts
.venv/bin/python audit_finops.py
```

---

## 📜 Revue d'Architecture Well-Architected

Consultez le rapport formel complet dans :
👉 [`05-finops-observability/WELL_ARCHITECTED_REVIEW.md`](05-finops-observability/WELL_ARCHITECTED_REVIEW.md)
