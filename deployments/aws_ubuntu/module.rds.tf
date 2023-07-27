module "rds" {
  source = "../../terraform/aws/rds"

  create          = !local.db_use_docker
  prefix          = local.prefix
  subnet_ids      = module.vpc-data.subnet_ids
  engine          = local.db_engine
  engine_version  = local.db_engine_version
  parameter_group = local.db_parameter_group
  instance_type   = local.db_instance_type
  instance_count  = local.db_instance_count

  root_username = lookup(local.db, "root_username", "postgres")
  root_password = lookup(local.db, "root_password", null)

  availability_zones = module.vpc-data.availability_zones

  tags = local.default_tags

  depends_on = [
    module.vpc-data,
    module.sg
  ]
}
