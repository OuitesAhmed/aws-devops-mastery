# 🏛️ Architecture Globale de la Plateforme AWS DevOps

Ce document présente l'architecture globale de la plateforme déployée, articulant la gouvernance multi-comptes, la CI/CD Zero-Secret, la sécurité CIS Benchmark, le réseau 3-tiers, le Serverless événementiel et l'observabilité unifiée.

---

## 🗺️ Schéma d'Architecture Global (Vue Unifiée)

```mermaid
flowchart TD
    %% EXTERNAL ACTORS
    Dev["👨‍💻 Développeur / DevOps (Local)"]
    GHRunner["🤖 GitHub Actions Runner (CI/CD)"]
    WebClient["🌐 Client Web / API (Navigateur / curl)"]
    AdminEmail["📧 Administrateur (ouites_ahmed@outlook.fr)"]

    %% GITHUB OIDC AUTH
    subgraph GitOpsFederation["🔐 Fédération GitOps Zero-Secret"]
        GHOIDC["GitHub OIDC Provider\n(token.actions.githubusercontent.com)"]
        AWSSTS["AWS STS\n(AssumeRoleWithWebIdentity)"]
        DeployerRole["Rôle IAM Déploiement\n(github-actions-deployer-role)"]
    end

    %% AWS ENVIRONMENT
    subgraph AWSOrg["☁️ AWS Organizations (o-y0nr29zt45)"]
        
        %% MANAGEMENT ACCOUNT
        subgraph MgmtAccount["Compte Maître / Management (825651620434)"]
            RootOU["Organisation Root (r-2lx7)"]
            SCPs["Service Control Policies (SCPs)\n(FullAWSAccess)"]
            RootOU --- SCPs
        end

        %% WORKLOAD ACCOUNT
        subgraph WorkloadAccount["Compte de Travail / Workload (453388806918 - Région Paris eu-west-3)"]
            
            %% FINOPS GUARDRAIL
            subgraph FinOpsGuardrail["00. Garde-Fou FinOps"]
                Budget["AWS Budgets\n(Plafond 5,00 $/mois\nAlertes 80% & 100%)"]
            end

            %% SECURITY BASELINE
            subgraph SecBaseline["01. Security Baseline & Audit (CIS Benchmark)"]
                S3PublicBlock["S3 Account Public Access Block\n(Anti-Fuite de Données)"]
                IAMPolicy["IAM Password Policy (14 chars)"]
                CloudTrail["AWS CloudTrail Multi-Région\n(Validation d'Intégrité SHA-256)"]
                S3Audit["Bucket S3 Logs\n(Chiffré AES256, TLS Strict, Versionné)"]
                GuardDuty["Amazon GuardDuty\n(Détecteur d'Intrusion IA)"]
                
                CloudTrail --> S3Audit
                GuardDuty -. Analyse .-> CloudTrail
            end

            %% PROJECT 2: 3-TIER NETWORK & ECS FARGATE
            subgraph VPCNet["02. Réseau 3-Tiers & Compute ECS Fargate (VPC 10.0.0.0/16)"]
                IGW["Internet Gateway (dev-igw)"]
                
                subgraph TierPublic["Tier 1 : Public (Subnets eu-west-3a / 3b)"]
                    ALB["Application Load Balancer\n(dev-app-alb - Port 80)"]
                    ALBSG["SG: dev-alb-sg\n(Ingress: 0.0.0.0/0)"]
                end

                subgraph TierApp["Tier 2 : Privé Applicatif (Subnets 10.0.10.0/24 & 11.0/24)"]
                    Fargate["Amazon ECS Fargate (dev-ecs-cluster)\n(Conteneurs Apache / Web-App)"]
                    ECSSG["SG: dev-ecs-tasks-sg\n(Ingress: UNIQUEMENT depuis dev-alb-sg)"]
                end

                subgraph TierDB["Tier 3 : Privé Données (Subnets 10.0.20.0/24 & 21.0/24)"]
                    DBSubnets["DB Subnet Group (Multi-AZ)"]
                    DBSG["SG: dev-database-sg\n(Ingress: Port 5432 depuis dev-ecs-tasks-sg)"]
                end

                IGW --> ALB
                ALB -->|Trafic HTTP Relayé| Fargate
                Fargate -.->|Futures Requêtes SQL| DBSubnets
            end

            %% PROJECT 3: SERVERLESS EVENT-DRIVEN
            subgraph ServerlessEDA["03. Architecture Serverless Événementielle (AWS CDK TypeScript)"]
                APIGW["Amazon API Gateway (HTTP)\n(POST /orders)"]
                LambdaProducer["Lambda Ingestion (order-producer)\n(ARM64 Graviton Node.js 22)"]
                EventBus["Amazon EventBridge (orders-event-bus)\n(Source: orders.service)"]
                EventRule["Règle de Filtrage\n(detail-type: OrderPlaced)"]
                SQSDLQ["Amazon SQS (orders-processing-dlq)\n(Dead-Letter Queue - Rétention 14j)"]
                LambdaConsumer["Lambda Worker (order-consumer)\n(ARM64 Graviton Node.js 22)"]
                DynamoDB[("Amazon DynamoDB (orders-table)\n(Mode PAY_PER_REQUEST - Clé: orderId)")]

                APIGW -->|Invocation Synchrone| LambdaProducer
                LambdaProducer -->|PutEvents| EventBus
                EventBus -->|Routage| EventRule
                EventRule -->|Événement Valide| LambdaConsumer
                EventRule -.->|Échecs après retries| SQSDLQ
                LambdaConsumer -->|PutItem (CONFIRMED)| DynamoDB
            end

            %% PROJECT 5: OBSERVABILITY & FINOPS
            subgraph Observability["05. Observabilité & Alerting (CloudWatch)"]
                CWLogs["CloudWatch Logs\n(/ecs/dev-app & /aws/lambda/*)"]
                CWDashboard["Dashboard Unifié As Code\n(Platform-Unified-Observability)"]
                CWAlarms["Alarmes Métriques\n(Erreurs Lambda > 0 / DLQ Messages > 0)"]
                SNSTopic["Amazon SNS Topic\n(platform-critical-alerts-topic)"]
                
                CWLogs -.-> CWDashboard
                LambdaProducer -. Métriques .-> CWDashboard
                LambdaConsumer -. Métriques .-> CWDashboard
                SQSDLQ -. Métriques .-> CWDashboard
                DynamoDB -. Métriques .-> CWDashboard
                
                CWAlarms -->|Déclenche alerte| SNSTopic
            end

        end
    end

    %% EXTERNAL FLOWS
    Dev -->|git push| GHRunner
    GHRunner -->|1. Demande JWT| GHOIDC
    GHOIDC -->|2. JWT Signé| GHRunner
    GHRunner -->|3. sts:AssumeRoleWithWebIdentity| AWSSTS
    AWSSTS -->|4. Clés temporaires 1h| DeployerRole
    DeployerRole -->|5. Déploiement IaC| WorkloadAccount

    WebClient -->|Requête HTTP Port 80| ALB
    WebClient -->|POST /orders| APIGW

    Budget -.->|Notification 80% / 100%| AdminEmail
    SNSTopic -.->|Notification critique email| AdminEmail
```

---

## 🔍 Les 6 Piliers Architecturaux

### 1. Gouvernance Multi-Comptes (AWS Organizations)
* Séparation stricte entre le **Management Account** (`825651620434`) dédié à la facturation / SCPs et le **Workload Account** (`453388806918`) hébergeant les ressources techniques.
* Politiques de contrôle de service (**SCPs**) héritées depuis la racine `Root`.

### 2. CI/CD GitOps Zero-Secret (IAM OIDC Federation)
* Fin des clés statiques d'API à durée indéfinie.
* GitHub Actions s'authentifie par échange cryptographique de jetons OpenID Connect (OIDC) avec **AWS STS**, obtenant des identifiants valides seulement 1 heure.

### 3. Sécurité & Défense en Profondeur (CIS Benchmark)
* **CloudTrail Multi-Région** avec validation d'intégrité SHA-256 (non-répudiation des logs).
* **S3 Account Public Access Block** : aucun bucket ne peut fuiter publiquement.
* **Amazon GuardDuty** : détection d'anomalies réseau et de compromission en temps réel.

### 4. Réseau 3-Tiers Zero-Trust (Terraform)
* Isolation stricte par subnets : **Public** (ALB), **Privé App** (ECS Fargate), **Privé Données** (RDS / Aurora).
* Security Groups croisés : les conteneurs ECS n'acceptent **que** le trafic relayé par l'ALB, et la base n'accepte **que** le port 5432 venant d'ECS.

### 5. Serverless Event-Driven Architecture (AWS CDK TypeScript)
* Découplage total via **Amazon EventBridge**.
* Performance et économies grâce aux puces **ARM64 Graviton**.
* Résilience avec **SQS Dead-Letter Queue (DLQ)** et stockage NoSQL scalable sans serveur (**Amazon DynamoDB** en mode *Pay-per-request*).

### 6. Observabilité & FinOps
* **Tableau de bord CloudWatch unifié** : métriques consolidées API Gateway, Lambdas, DynamoDB et SQS DLQ.
* **Alarmes proactives** reliées à un topic SNS alertant par email.
* **Budget Guardrail** (5 $/mois) pour garantir l'absence totale de dépassement.
