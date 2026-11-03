# Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway (IGW) pour le trafic sortant et entrant public
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ==========================================
# 1. TIER PUBLIC (ALB, Bastion, NAT)
# ==========================================
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1) # 10.0.1.0/24, 10.0.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "Public"
  }
}

# Table de routage publique pointant vers l'Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# 2. TIER PRIVÉ APPLICATIF (ECS / EKS)
# ==========================================
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # 10.0.10.0/24, 10.0.11.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-app-subnet-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "Private-App"
  }
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-app-rt"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# ==========================================
# 3. TIER PRIVÉ BASE DE DONNÉES (RDS / Aurora)
# ==========================================
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20) # 10.0.20.0/24, 10.0.21.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-db-subnet-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "Private-DB"
  }
}

# DB Subnet Group prêt pour RDS / Aurora
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-db-subnet-group"
  description = "Database subnet group pour RDS / Aurora Multi-AZ"
  subnet_ids  = aws_subnet.private_db[*].id

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

