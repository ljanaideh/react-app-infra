module "vpc_ha" {
  source   = "../vpc_ha"
  app_name = var.app_name
}

module "ecr" {
  source   = "../ecr"
  app_name = var.app_name
}

module "fargate_app" {
  source             = "../fargate_app"
  app_name           = var.app_name
  aws_region         = var.aws_region
  vpc_id             = module.vpc_ha.vpc_id
  public_subnet_ids  = module.vpc_ha.public_subnet_ids
  ecr_repository_url = module.ecr.repository_url
  image_tag          = var.image_tag
  desired_count      = var.desired_count
}
