# =========================
# Internet Gateway
# =========================
resource "aws_internet_gateway" "IGW_CarePlus" {
  vpc_id = aws_vpc.VPC_CarePlus.id #Associando o IGW à VPC
  tags   = { Name = "IGW_CarePlus" }
}