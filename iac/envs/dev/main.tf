locals {
  name_prefix   = lower("${var.project}-${var.environment}")
  service_names = toset(keys(var.services))

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidr     = var.app_subnet_cidr
  tags                = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix   = local.name_prefix
  vpc_id        = module.network.vpc_id
  service_ports = toset([for service in values(var.services) : service.port])
  tags          = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  name_prefix   = local.name_prefix
  service_names = local.service_names
  tags          = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix           = local.name_prefix
  service_names         = local.service_names
  image_retention_count = var.ecr_image_retention_count
  tags                  = local.common_tags
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix                        = local.name_prefix
  services                           = var.services
  log_retention_days                 = var.log_retention_days
  aws_region                         = var.aws_region
  container_image                    = var.container_image
  execution_role_arn                 = module.iam.execution_role_arn
  task_role_arns                     = module.iam.task_role_arns
  app_subnet_ids                     = module.network.app_subnet_ids
  task_security_group_id             = module.security.tasks_security_group_id
  target_group_arns                  = module.alb.target_group_arns
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  cpu_target_value                   = var.cpu_target_value
  scale_out_cooldown                 = var.scale_out_cooldown
  scale_in_cooldown                  = var.scale_in_cooldown
  cpu_alarm_threshold                = var.cpu_alarm_threshold
  cpu_alarm_evaluation_periods       = var.cpu_alarm_evaluation_periods
  alarm_actions                      = var.alarm_actions
  tags                               = local.common_tags

  depends_on = [module.iam]
}

module "alb" {
  source = "../../modules/alb"

  name_prefix                = local.name_prefix
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  security_group_id          = module.security.alb_security_group_id
  certificate_arn            = var.certificate_arn
  services                   = var.services
  health_check_path          = var.health_check_path
  health_check_matcher       = var.health_check_matcher
  alb_5xx_threshold_percent  = var.alb_5xx_threshold_percent
  alb_5xx_evaluation_periods = var.alb_5xx_evaluation_periods
  alarm_actions              = var.alarm_actions
  tags                       = local.common_tags
}
