module "cache" {
  source = "../../terraform/aws/cache"

  create = !local.cache_use_docker

  prefix             = local.prefix
  instance_type      = local.cache_instance_type
  instance_count     = local.cache_instance_count
  engine             = local.cache_engine
  engine_version     = local.cache_engine_version
  parameter_group    = local.cache_parameter_group
  availability_zones = module.vpc-data.availability_zones
  security_group_ids = [module.sg.cache_sg_id]
  subnet_ids  = module.vpc-data.subnet_ids


  tags = local.default_tags

  depends_on = [
    module.vpc-data,
    module.sg
  ]

}
