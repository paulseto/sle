module "sl" {
  source = "../../terraform/aws/sl"

  instance_type  = local.sl_type
  instance_count = local.sl_count
  instance_size  = local.sl_size

  hostname         = local.sl_hostname
  hostname_pattern = local.sl_hostname_pattern
  domain           = local.domain
  iam_role         = local.sl_iam_role
  ami_id           = local.sl_ami_id
  ami_name_filter  = local.sl_ami_name_filter
  default_tags     = local.default_tags
  subnets          = module.vpc-data.subnet_ids
  efs_dns          = local.efs_create ? module.efs.dns_name : null
  cache_dns        = module.cache.primary_endpoint
  db_dns           = module.rds.endpoint
  db_name          = module.rds.database_name
  master_username  = module.rds.master_username
  master_password  = module.rds.master_password
  port             = module.rds.port
  lb_secret        = local.sl_lb_secret

  db_use_docker      = local.db_use_docker
  db_docker_image    = local.db_docker_image
  cache_use_docker   = local.cache_use_docker
  cache_docker_image = local.cache_docker_image
  sl_image_tag       = local.sl_image_tag

  security_groups = [
    module.sg.https_sg_id,
    module.sg.ssh_sg_id
  ]

  ssh_user = local.ssh_user
  key_name = local.ssh_key_name
  key_file = local.ssh_key_file

  ssl_crt_file = local.ssl_crt_file
  ssl_key_file = local.ssl_key_file

  tenant_crt_file = local.sl_tenant_crt_file
  tenant_key_file = local.sl_tenant_key_file

  hostname_to_ip            = module.eip.hostname_to_ip
  hostname_to_allocation_id = module.eip.hostname_to_allocation_id

  enable_tenants = local.sl_enable_tenants
  tenants = local.sl_tenants

  depends_on = [
    module.efs,
    module.cache,
    module.rds,
    module.sg,
    module.vpc-data
  ]
}
