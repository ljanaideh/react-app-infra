output "app_url" {
  value       = "http://${aws_instance.app.public_dns}:${var.container_port}"
  description = "EC2 public DNS on the app port (HTTP)."
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_instance.app.public_ip
}
