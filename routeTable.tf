# =========================
# Route Table Pública
# =========================
resource "aws_route_table" "RT_Publica_CarePlus" {
  vpc_id = aws_vpc.VPC_CarePlus.id #Associando a Route Table à VPC
  route {
    cidr_block = var.ips_qualquer_lugar_v4            #Rota para Internet
    gateway_id = aws_internet_gateway.IGW_CarePlus.id #Associando a rota ao IGW
  }
  tags = { Name = "RT_Publica_CarePlus" }
}

resource "aws_route_table_association" "Assoc_Publica1" {
  subnet_id      = aws_subnet.Subnet_Publica1_CarePlus.id #Associando a subnet pública 1 à Route Table
  route_table_id = aws_route_table.RT_Publica_CarePlus.id #Associando a Route Table à subnet pública 1
}

resource "aws_route_table_association" "Assoc_Publica2" {
  subnet_id      = aws_subnet.Subnet_Publica2_CarePlus.id
  route_table_id = aws_route_table.RT_Publica_CarePlus.id
}

# =========================
# Route Table Privada
# Sem rota para internet — o backend não precisa de saída direta.
# O acesso ao S3 é feito via VPC Gateway Endpoint (abaixo).
# =========================
resource "aws_route_table" "RT_Privada_CarePlus" {
  vpc_id = aws_vpc.VPC_CarePlus.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_CarePlus.id
  }

  tags = { Name = "RT_Privada_CarePlus" }
}

resource "aws_route_table_association" "Assoc_Privada" {
  subnet_id      = aws_subnet.Subnet_Privada_CarePlus.id
  route_table_id = aws_route_table.RT_Privada_CarePlus.id
}

# =========================
# VPC Gateway Endpoint para S3
# Permite que a EC2 privada acesse o S3 sem NAT Gateway (gratuito).
# O endpoint adiciona rotas automáticas à RT_Privada.
# =========================
resource "aws_vpc_endpoint" "S3_Endpoint_CarePlus" {
  vpc_id            = aws_vpc.VPC_CarePlus.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.RT_Privada_CarePlus.id]

  tags = { Name = "S3_Endpoint_CarePlus" }
}