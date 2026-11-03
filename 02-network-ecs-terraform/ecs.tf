# Cluster Amazon ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.environment}-ecs-cluster"
  }
}

# Groupe de logs CloudWatch pour les conteneurs
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.environment}-app"
  retention_in_days = 7

  tags = {
    Name = "${var.environment}-ecs-logs"
  }
}

# Rôle IAM d'exécution Fargate (Téléchargement d'images ECR/DockerHub & Logs)
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Rôle IAM applicatif de tâche ECS (accès aux SDK AWS par l'application elle-même)
resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Politique IAM permettant à l'agent ECS de récupérer les secrets chiffrés dans AWS Secrets Manager
resource "aws_iam_policy" "ecs_secrets" {
  name        = "${var.environment}-ecs-secrets-policy"
  description = "Allows ECS agent to retrieve secrets from AWS Secrets Manager without hardcoding"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = concat(
          [aws_secretsmanager_secret.app_config.arn],
          var.enable_database ? [aws_rds_cluster.aurora[0].master_user_secret[0].secret_arn] : []
        )
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_secrets.arn
}

# Task Definition ECS Fargate (Légère : 0.25 vCPU, 512 Mo RAM)
# Injection Zero-Secret des identifiants et clés d'API depuis Secrets Manager
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "web-app"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = concat(
        [
          {
            name  = "ENVIRONMENT"
            value = var.environment
          }
        ],
        var.enable_database ? [
          {
            name  = "DB_HOST"
            value = aws_rds_cluster.aurora[0].endpoint
          },
          {
            name  = "DB_PORT"
            value = tostring(aws_rds_cluster.aurora[0].port)
          },
          {
            name  = "DB_NAME"
            value = var.db_name
          }
        ] : []
      )
      secrets = concat(
        [
          {
            name      = "API_KEY"
            valueFrom = "${aws_secretsmanager_secret.app_config.arn}:api_key::"
          },
          {
            name      = "JWT_SECRET"
            valueFrom = "${aws_secretsmanager_secret.app_config.arn}:jwt_secret::"
          }
        ],
        var.enable_database ? [
          {
            name      = "DB_USER"
            valueFrom = "${aws_rds_cluster.aurora[0].master_user_secret[0].secret_arn}:username::"
          },
          {
            name      = "DB_PASSWORD"
            valueFrom = "${aws_rds_cluster.aurora[0].master_user_secret[0].secret_arn}:password::"
          }
        ] : []
      )
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])
}

# Service ECS Fargate avec intégration ALB
resource "aws_ecs_service" "app" {
  name            = "${var.environment}-web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "web-app"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Name = "${var.environment}-web-service"
  }
}

