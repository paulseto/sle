module "gl" {
  source = "../../terraform/aws/gl"

  instance_type  = local.gl_type
  instance_count = local.gl_count
  instance_size  = local.gl_size

  hostname         = local.gl_hostname
  hostname_pattern = local.gl_hostname_pattern
  domain           = local.domain
  iam_role         = local.gl_iam_role
  ami_id           = local.gl_ami_id
  ami_name_filter  = local.gl_ami_name_filter
  default_tags     = local.default_tags
  subnets          = module.vpc-data.subnet_ids

  security_groups = [
    module.sg.https_sg_id,
    module.sg.ssh_sg_id
  ]

  ssh_user = local.ssh_user
  key_name = local.ssh_key_name
  key_file = local.ssh_key_file

  ssl_crt_file = local.ssl_crt_file
  ssl_key_file = local.ssl_key_file

  sl_hostname = module.sl.hostname
  sl_secret   = module.sl.secret

  admin_email    = local.gl_admin_email
  admin_password = local.gl_admin_password
  admin_name     = local.gl_admin_name

  hostname_to_ip            = module.eip.hostname_to_ip
  hostname_to_allocation_id = module.eip.hostname_to_allocation_id

  depends_on = [
    module.cache,
    module.sg,
    module.vpc-data,
    module.sl
  ]
}
