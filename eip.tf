# =====================================================
# Elastic IPs - Backend e RabbitMQ
# Garantem IP fixo entre reboots/recreates.
# =====================================================
resource "aws_eip" "EIP_NAT" {
  domain = "vpc"
  tags   = { Name = "EIP_NAT_CarePlus" }
}

resource "aws_nat_gateway" "NAT_CarePlus" {
  allocation_id = aws_eip.EIP_NAT.id
  subnet_id     = aws_subnet.Subnet_Publica1_CarePlus.id

  tags = { Name = "NAT_CarePlus" }

  depends_on = [aws_internet_gateway.IGW_CarePlus]
}

resource "aws_eip" "EIP_RabbitMQ" {
  instance = aws_instance.EC2_RabbitMQ_CarePlus.id
  domain   = "vpc"

  tags = { Name = "EIP_RabbitMQ_CarePlus" }
}

resource "aws_eip" "EIP_Frontend" {
  instance = aws_instance.EC2_Frontend_CarePlus.id
  domain   = "vpc"

  tags = { Name = "EIP_Frontend_CarePlus" }
}
