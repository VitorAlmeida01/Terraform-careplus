# =====================================================
# SG - ALB
# 80 → HTTP público (internet → ALB)
# =====================================================
resource "aws_security_group" "SG_ALB_CarePlus" {
  name        = "SG_ALB_CarePlus"
  description = "ALB publico - aceita HTTP da internet e encaminha ao backend"
  vpc_id      = aws_vpc.VPC_CarePlus.id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG_ALB_CarePlus" }
}

# =====================================================
# SG - Backend + DB
# 8080 → Spring Boot (ALB e frontend via VPC)
# 22   → SSH
# =====================================================
resource "aws_security_group" "SG_Backend_CarePlus" {
  name        = "SG_Backend_CarePlus"
  description = "Backend privado (Spring Boot) + MySQL - acesso somente via VPC"
  vpc_id      = aws_vpc.VPC_CarePlus.id

  ingress {
    description = "Spring Boot (ALB e frontend via VPC)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "SSH (somente via jump host na subnet publica)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG_Backend_CarePlus" }
}

# =====================================================
# SG - RabbitMQ + Mensageria (subnet privada)
# 5672  → AMQP — somente dentro da VPC
# 15672 → Painel Web do RabbitMQ — somente dentro da VPC (acesso via SSH tunnel)
# 8081  → Mensageria Spring Boot — somente dentro da VPC
# 22    → SSH — somente dentro da VPC (jump host via frontend)
# =====================================================
resource "aws_security_group" "SG_RabbitMQ_CarePlus" {
  name        = "SG_RabbitMQ_CarePlus"
  description = "RabbitMQ broker + Mensageria + management UI (acesso somente via VPC)"
  vpc_id      = aws_vpc.VPC_CarePlus.id

  ingress {
    description = "AMQP"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "RabbitMQ Management UI (acesso via SSH tunnel)"
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Mensageria Spring Boot"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "SSH (jump host via frontend)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG_RabbitMQ_CarePlus" }
}

# =====================================================
# SG - Frontend (uso futuro)
# 80, 5173, 8080, 22 - liberados para teste
# =====================================================
resource "aws_security_group" "SG_Frontend_CarePlus" {
  name        = "SG_Frontend_CarePlus"
  description = "Frontend (React/Vite)"
  vpc_id      = aws_vpc.VPC_CarePlus.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vite Dev Server"
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Generic 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG_Frontend_CarePlus" }
}
