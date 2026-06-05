# =====================================================
# Outputs - tudo que você precisa saber depois do apply
# =====================================================

output "backend_private_ip" {
  description = "IP privado da EC2 do backend (use como BACKEND_PRIVATE_IP no GitHub Secret e como jump host)"
  value       = aws_instance.EC2_Backend_CarePlus.private_ip
}

output "backend_url" {
  description = "URL do backend via ALB (use no Bruno IDE)"
  value       = "http://${aws_lb.LB_CarePlus.dns_name}"
}

output "backend_swagger" {
  description = "Swagger UI do backend via ALB"
  value       = "http://${aws_lb.LB_CarePlus.dns_name}/swagger-ui.html"
}

output "rabbitmq_private_ip" {
  description = "IP privado do RabbitMQ (usado internamente pelo backend e para SSH tunnel)"
  value       = aws_instance.EC2_RabbitMQ_CarePlus.private_ip
}

output "rabbitmq_amqp" {
  description = "Endpoint AMQP interno (somente dentro da VPC)"
  value       = "${aws_instance.EC2_RabbitMQ_CarePlus.private_ip}:5672"
}

output "rabbitmq_management_url" {
  description = "Painel Web do RabbitMQ via SSH tunnel: ssh -L 15672:<rabbitmq_private_ip>:15672 ubuntu@<frontend_eip> -i vockey.pem"
  value       = "http://${aws_instance.EC2_RabbitMQ_CarePlus.private_ip}:15672 (via tunnel)"
}

output "mensageria_url" {
  description = "URL da Mensageria (somente dentro da VPC)"
  value       = "http://${aws_instance.EC2_RabbitMQ_CarePlus.private_ip}:8081"
}

output "mensageria_swagger" {
  description = "Swagger UI da Mensageria (somente dentro da VPC)"
  value       = "http://${aws_instance.EC2_RabbitMQ_CarePlus.private_ip}:8081/swagger-ui.html"
}

output "mensageria_logs_access" {
  description = "Comando para acessar logs da Mensageria via SSH (jump host pelo frontend)"
  value       = "ssh -i vockey.pem -J ubuntu@${aws_eip.EIP_Frontend.public_ip} ubuntu@${aws_instance.EC2_RabbitMQ_CarePlus.private_ip} 'tail -f /var/log/mensageria.log'"
}

output "alb_dns" {
  description = "DNS público do ALB (alternativa ao EIP do backend)"
  value       = aws_lb.LB_CarePlus.dns_name
}

output "deploy_bucket" {
  description = "Bucket S3 onde o JAR e os SQLs estão hospedados"
  value       = aws_s3_bucket.Bucket_CarePlus_Deploy.bucket
}

output "ssh_backend" {
  description = "Comando SSH para a EC2 do backend via jump host (frontend)"
  value       = "ssh -i vockey.pem -J ubuntu@${aws_eip.EIP_Frontend.public_ip} ubuntu@${aws_instance.EC2_Backend_CarePlus.private_ip}"
}

output "ssh_rabbitmq" {
  description = "Comando SSH para a EC2 do RabbitMQ (jump host via frontend)"
  value       = "ssh -i vockey.pem -J ubuntu@${aws_eip.EIP_Frontend.public_ip} ubuntu@${aws_instance.EC2_RabbitMQ_CarePlus.private_ip}"
}

output "frontend_url" {
  description = "URL do frontend (Nginx)"
  value       = "http://${aws_eip.EIP_Frontend.public_ip}"
}

output "ssh_frontend" {
  description = "Comando SSH para a EC2 do frontend"
  value       = "ssh -i vockey.pem ubuntu@${aws_eip.EIP_Frontend.public_ip}"
}

output "deploy_frontend" {
  description = "O build (dist/) é enviado automaticamente para o S3 pelo terraform apply e baixado pela EC2 no boot."
  value       = "s3://${aws_s3_bucket.Bucket_CarePlus_Deploy.bucket}/frontend/"
}
