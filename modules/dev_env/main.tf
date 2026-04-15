module "vpc_ha" {
  source   = "../vpc_ha"
  app_name = var.app_name
}

module "ecr" {
  source   = "../ecr"
  app_name = var.app_name
}

locals {
  name_safe    = replace(var.app_name, "_", "-")
  image_uri    = "${module.ecr.repository_url}:${var.image_tag}"
  ecr_registry = split("/", module.ecr.repository_url)[0]
}

resource "aws_security_group" "ec2" {
  name        = substr("${local.name_safe}-ec2", 0, 255)
  description = "EC2 app ingress"
  vpc_id      = module.vpc_ha.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2" {
  name = substr("${local.name_safe}-ec2-role", 0, 64)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2" {
  name = substr("${local.name_safe}-ec2-prof", 0, 128)
  role = aws_iam_role.ec2.name
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_ha.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tmpl", {
    aws_region   = var.aws_region
    ecr_registry = local.ecr_registry
    image_uri    = local.image_uri
    host_port    = var.container_port
    inner_port   = var.container_port
  }))

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${local.name_safe}-ec2"
  }
}
