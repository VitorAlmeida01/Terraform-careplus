# =====================================================
# Application Load Balancer
# Aponta para a EC2 do BACKEND (porta 8080).
# Bruno IDE pode usar tanto o EIP quanto o DNS do ALB.
# =====================================================

resource "aws_lb" "LB_CarePlus" {
  name               = "lb-careplus"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.SG_ALB_CarePlus.id]

  subnets = [
    aws_subnet.Subnet_Publica1_CarePlus.id,
    aws_subnet.Subnet_Publica2_CarePlus.id
  ]

  tags = { Name = "LB_CarePlus" }
}

resource "aws_lb_target_group" "TG_Backend_CarePlus" {
  name        = "tg-careplus-back"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC_CarePlus.id
  target_type = "instance"

  health_check {
    path                = "/swagger-ui.html"
    matcher             = "200-399"
    port                = "8080"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = { Name = "TG_Backend_CarePlus" }
}

resource "aws_lb_listener" "LB_Listener_CarePlus" {
  load_balancer_arn = aws_lb.LB_CarePlus.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG_Backend_CarePlus.arn
  }
}

resource "aws_lb_target_group_attachment" "TG_Attach_Backend" {
  target_group_arn = aws_lb_target_group.TG_Backend_CarePlus.arn
  target_id        = aws_instance.EC2_Backend_CarePlus.id
  port             = 8080
}
