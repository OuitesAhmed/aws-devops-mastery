# AWS Well-Architected Framework Review (WAR)
*Rapport d'audit & Revue d'Architecture des Piliers AWS*

Ce document formalise la conformité de l'ensemble des projets déployés dans ce dépôt avec les **6 Piliers du AWS Well-Architected Framework**.

---

## 🏛️ Matrice de Conformité par Pilier

| Pilier AWS | Bonnes Pratiques Appliquées | Preuve d'Implémentation dans ce Dépôt |
|---|---|---|
| **1. Excellence Opérationnelle** | Infrastructure as Code à 100%, monitoring automatisé, pipelines CI/CD OIDC. | - Double maîtrise Terraform & AWS CDK.<br>- Workflows GitHub Actions OIDC sans clés API permanentes.<br>- Dashboard CloudWatch unifié et alarmes sur seuils d'erreurs. |
| **2. Sécurité** | Principe du moindre privilège, défense en profondeur, traçabilité immuable, chiffrement systématique. | - Multi-région CloudTrail avec validation d'intégrité SHA-256.<br>- S3 Account Public Access Block activé.<br>- Zero-Trust Security Groups chaînés (ALB -> ECS -> RDS).<br>- Détection d'intrusion en temps réel avec Amazon GuardDuty. |
| **3. Fiabilité** | Tolérance aux pannes, architectures découplées, files d'attente d'amortissement et Dead-Letter Queues (DLQ). | - Réseau Multi-AZ sur 2 Zones de Disponibilité distinctes.<br>- Architecture événementielle découplée via Amazon EventBridge.<br>- Gestion des pannes avec SQS Dead-Letter Queue (retention 14 jours). |
| **4. Efficacité des Performances** | Utilisation de processeurs modernes ARM64 Graviton, conteneurisation serverless, bases de données NoSQL adaptées. | - Lambdas compilées et exécutées sur architecture **ARM_64 Graviton** (20% plus rapides).<br>- Amazon ECS Fargate : dimensionnement chirurgical à 0.25 vCPU / 512 Mo.<br>- DynamoDB NoSQL pour des latences de lecture/écriture en millisecondes à un chiffre. |
| **5. Optimisation des Coûts (FinOps)** | Budgets de sécurité, arrêt des ressources oisives, mode à la demande (Pay-as-you-go). | - Alarme AWS Budgets à 5 $/mois avec alerte réelle (80%) et prévisionnelle (100%).<br>- DynamoDB en mode `PAY_PER_REQUEST` (coût 0,00 $ en idle).<br>- Évitement des NAT Gateways en environnement dev pour économiser 32 $/mois.<br>- Script d'audit automatique `audit_finops.py`. |
| **6. Durabilité** | Réduction de l'empreinte carbone via le Serverless et les puces Graviton à haute efficacité énergétique. | - Utilisation exclusive de processeurs AWS Graviton conçus sur mesure pour consommer jusqu'à 60% d'énergie en moins que les processeurs x86 équivalents.<br>- Serverless : aucune ressource de calcul allouée en idle. |

