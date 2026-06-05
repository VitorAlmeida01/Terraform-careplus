# =====================================================
# EC2 - RabbitMQ (Subnet privada — mesma AZ do backend)
# Sobe primeiro para que o IP privado seja conhecido
# pelo backend antes do user_data dele rodar.
# =====================================================
resource "aws_instance" "EC2_RabbitMQ_CarePlus" {
  ami                         = "ami-0b6c6ebed2801a5cb" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.Subnet_Privada_CarePlus.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.SG_RabbitMQ_CarePlus.id]
  iam_instance_profile        = "LabInstanceProfile"

  tags = { Name = "EC2_RabbitMQ_CarePlus" }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/scripts/rabbitmq.sh", {
    bucket_name = aws_s3_bucket.Bucket_CarePlus_Deploy.bucket
  })

  depends_on = [
    aws_s3_object.mensageria_jar,
    aws_nat_gateway.NAT_CarePlus,
    aws_route_table_association.Assoc_Privada,
  ]
}

# =====================================================
# EC2 - Backend + Banco de Dados (Subnet pública 1)
# Backend e MySQL rodam na mesma EC2 via Docker.
# =====================================================
resource "aws_instance" "EC2_Backend_CarePlus" {
  ami                         = "ami-0b6c6ebed2801a5cb" # Ubuntu 22.04 LTS
  instance_type               = "t3.small"              # mais memória para JAR + MySQL
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.Subnet_Privada_CarePlus.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.SG_Backend_CarePlus.id]
  iam_instance_profile        = "LabInstanceProfile"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tags = { Name = "EC2_Backend_CarePlus" }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 30
    volume_type = "gp3"
  }

  # Renderiza o script de bootstrap injetando IP privado do RabbitMQ e nome do bucket.
  user_data = templatefile("${path.module}/scripts/backend.sh.tpl", {
    rabbitmq_private_ip = aws_instance.EC2_RabbitMQ_CarePlus.private_ip
    bucket_name         = aws_s3_bucket.Bucket_CarePlus_Deploy.bucket
  })

  depends_on = [
    aws_instance.EC2_RabbitMQ_CarePlus,
    aws_s3_object.careplus_jar,
    aws_s3_object.careplus_consolidated_sql,
    aws_nat_gateway.NAT_CarePlus,
    aws_route_table_association.Assoc_Privada,
  ]
}

# =====================================================
# EC2 – Frontend (Subnet pública 1, mesma AZ do backend)
# Nginx serve os estáticos e faz proxy reverso → backend.
# =====================================================
resource "aws_instance" "EC2_Frontend_CarePlus" {
  ami                         = "ami-0b6c6ebed2801a5cb" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.Subnet_Publica1_CarePlus.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.SG_Frontend_CarePlus.id]
  iam_instance_profile        = "LabInstanceProfile"

  tags = { Name = "EC2_Frontend_CarePlus" }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"
  }

  # Injeta DNS do ALB e nome do bucket para o Nginx + s3 sync.
  # O DNS do ALB é estável — não muda se o backend for recriado.
  user_data = templatefile("${path.module}/scripts/frontend.sh", {
    alb_dns     = aws_lb.LB_CarePlus.dns_name
    bucket_name = aws_s3_bucket.Bucket_CarePlus_Deploy.bucket
  })

  depends_on = [
    aws_lb_listener.LB_Listener_CarePlus,
    aws_lb_target_group_attachment.TG_Attach_Backend,
    aws_s3_object.frontend_files,
  ]
}
