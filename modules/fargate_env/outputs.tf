output "app_url" {
  value       = "http://${module.fargate_app.alb_dns_name}"
  description = "Application Load Balancer URL (HTTP)"
}

output "alb_dns_name" {
  value = module.fargate_app.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.fargate_app.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.fargate_app.ecs_service_name
}
