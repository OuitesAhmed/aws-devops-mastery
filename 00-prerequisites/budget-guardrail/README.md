# 🛡️ AWS Budget Guardrail (Terraform)

Ce module Terraform déploie un budget mensuel avec deux alertes automatisées par email :
1. **80% du budget réel atteint** (ex: 4$ sur 5$).
2. **100% du budget prévisionnel dépassé** (AWS prédit que vous allez dépasser d'ici la fin du mois).

## 🚀 Déploiement

1. Copiez le fichier d'exemple :
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Éditez `terraform.tfvars` avec votre adresse email.
3. Initialisez et appliquez :
   ```bash
   terraform init
   terraform apply
   ```
4. Vous recevrez un email d'AWS Budgets pour confirmer et vérifier la création du budget.

