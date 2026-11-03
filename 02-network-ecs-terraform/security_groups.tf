# 1. Security Group pour l'Application Load Balancer (Exposé Internet)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow inbound HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic to ECS containers"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# 2. Security Group pour les tâches ECS Fargate (Zero-Trust)
resource "aws_security_group" "ecs" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Allow inbound traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Restricted app traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound traffic to pull images and reach APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ecs-tasks-sg"
  }
}

# 3. Security Group pour la Base de Données (RDS / Aurora)
resource "aws_security_group" "db" {
  name        = "${var.environment}-database-sg"
  description = "Allow DB queries from ECS containers only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS containers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "No outbound required for DB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-database-sg"
  }
}
