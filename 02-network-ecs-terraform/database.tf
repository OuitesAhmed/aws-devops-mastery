# ==============================================================================
# Amazon Aurora Serverless v2 PostgreSQL
# Modèle Haute Disponibilité Multi-AZ & Scaling automatique 0.5 - 1.0 ACU
# ==============================================================================

# Cluster Aurora Serverless v2 PostgreSQL
# Note FinOps : Conditionné par var.enable_database (false par défaut = 0,00$/mois au repos)
resource "aws_rds_cluster" "aurora" {
  count                           = var.enable_database ? 1 : 0
  cluster_identifier              = "${var.environment}-aurora-pg"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned" # Requis pour Aurora Serverless v2
  engine_version                  = var.aurora_engine_version
  database_name                   = var.db_name
  master_username                 = var.db_username
  manage_master_user_password     = true # Géré nativement par AWS Secrets Manager (zéro mot de passe en clair dans le code/state)
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  skip_final_snapshot             = true
  deletion_protection             = false
  apply_immediately               = true

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_min_capacity # 0.5 ACU (~1 Go RAM)
    max_capacity = var.aurora_max_capacity # 1.0 ACU (~2 Go RAM)
  }

  tags = {
    Name = "${var.environment}-aurora-postgresql"
  }
}

# Instance de calcul du cluster Aurora (db.serverless)
resource "aws_rds_cluster_instance" "aurora_instance" {
  count               = var.enable_database ? 1 : 0
  identifier          = "${var.environment}-aurora-pg-instance-1"
  cluster_identifier  = aws_rds_cluster.aurora[0].id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.aurora[0].engine
  engine_version      = aws_rds_cluster.aurora[0].engine_version
  publicly_accessible = false
  apply_immediately   = true

  tags = {
    Name = "${var.environment}-aurora-instance-1"
  }
}
