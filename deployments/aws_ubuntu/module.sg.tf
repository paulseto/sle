module "sg" {
  source = "../../terraform/aws/sg"

  vpc_id             = module.vpc-data.vpc_id
  prefix             = local.prefix
  default_tags       = local.default_tags
  subnet_cidr_blocks = module.vpc-data.subnet_cidr_blocks

  create_efs   = local.efs_create
  create_cache = !local.cache_use_docker
  create_db    = !local.db_use_docker

  depends_on = [module.vpc-data]

}
