# =========================
# Subnets públicas /24
# =========================
resource "aws_subnet" "Subnet_Publica1_CarePlus" {
  vpc_id                  = aws_vpc.VPC_CarePlus.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a" #Availability Zone A
  map_public_ip_on_launch = true         #Deixar o IP Público automático para as instâncias lançadas nessa subnet

  tags = {
    Name = "Subnet_Publica1_CarePlus"
  }
}

resource "aws_subnet" "Subnet_Publica2_CarePlus" {
  vpc_id                  = aws_vpc.VPC_CarePlus.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b" #Availability Zone B
  map_public_ip_on_launch = true         #Deixar o IP Público automático para as instâncias lançadas nessa subnet

  tags = {
    Name = "Subnet_Publica2_CarePlus"
  }
}

# =========================
# Subnet privada /24
# =========================
resource "aws_subnet" "Subnet_Privada_CarePlus" {
  vpc_id            = aws_vpc.VPC_CarePlus.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "Subnet_Privada_CarePlus" }
}