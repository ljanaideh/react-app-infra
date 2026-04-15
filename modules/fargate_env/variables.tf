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
