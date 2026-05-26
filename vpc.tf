# =========================
# VPC /22
# =========================
resource "aws_vpc" "VPC_CarePlus" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "VPC_CarePlus" }
}