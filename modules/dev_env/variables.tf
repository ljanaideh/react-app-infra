variable "app_name" {
  default = "react-app-dev"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "image_tag" {
  default = "latest"
}

variable "instance_type" {
  default     = "t3.small"
  description = "EC2 Spot instance type (x86_64 AL2023 AMI)."
}

variable "container_port" {
  default     = 80
  description = "Host and container port for the app (HTTP)."
}
