module "vpc" {
  source     = "../../modules/vpc"
  app_name   = var.app_name
  aws_region = var.aws_region
}

module "ecr" {
  source   = "../../modules/ecr"
  app_name = var.app_name
}

module "ec2" {
  source              = "../../modules/ec2"
  app_name            = var.app_name
  aws_region          = var.aws_region
  ecr_repository_url  = module.ecr.repository_url
  subnet_id           = module.vpc.public_subnet_id
  security_group_id   = module.vpc.security_group_id
  instance_type       = var.instance_type
  image_tag           = var.image_tag
}
