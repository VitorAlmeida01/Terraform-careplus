# =====================================================
# Network ACL - Subnets Públicas
# Liberada para teste (a SG já restringe por porta).
# =====================================================
resource "aws_network_acl" "NACL_Publica_CarePlus" {
  vpc_id = aws_vpc.VPC_CarePlus.id
  subnet_ids = [
    aws_subnet.Subnet_Publica1_CarePlus.id,
    aws_subnet.Subnet_Publica2_CarePlus.id,
  ]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "NACL_Publica_CarePlus" }
}

# =====================================================
# Network ACL - Subnet Privada (mantida sem uso ativo)
# =====================================================
resource "aws_network_acl" "NACL_Privada_CarePlus" {
  vpc_id     = aws_vpc.VPC_CarePlus.id
  subnet_ids = [aws_subnet.Subnet_Privada_CarePlus.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/22"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "NACL_Privada_CarePlus" }
}
