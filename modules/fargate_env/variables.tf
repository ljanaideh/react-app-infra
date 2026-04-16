variable "app_name" {
  default = "react-app-dev-fargate"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "image_tag" {
  default = "latest"
}

variable "desired_count" {
  default     = 2
  description = "Fargate tasks (2 AZs, rolling deploy)."
}

variable "container_port" {
  type        = number
  default     = 80
  description = "Must match the process port inside the image (e.g. 80 for nginx/React, 4321 for EmDash SSR)."
}
