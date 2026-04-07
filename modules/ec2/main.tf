variable "app_name" {}
variable "aws_region" {}
variable "ecr_repository_url" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "instance_type" { default = "t4g.nano" }
variable "image_tag" { default = "latest" }

data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.app_name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_spot_instance_request" "app" {
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  spot_type                   = "persistent"
  wait_for_fulfillment        = true

  user_data_replace_on_change = true

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # v4 - space app updated
    set -ex
    dnf install -y docker
    systemctl enable docker && systemctl start docker
    sleep 5
    aws ecr get-login-password --region ${var.aws_region} \
      | docker login --username AWS --password-stdin ${var.ecr_repository_url}
    docker pull ${var.ecr_repository_url}:${var.image_tag}
    docker run -d --restart always -p 80:80 \
      --name ${var.app_name} \
      ${var.ecr_repository_url}:${var.image_tag}
  EOF
  )

  tags = { Name = var.app_name }
}

output "public_ip" { value = aws_spot_instance_request.app.public_ip }
