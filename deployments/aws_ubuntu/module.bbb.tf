module "bbb" {
  source = "../../terraform/aws/bbb"

  efs_dns = local.efs_create ? module.efs.dns_name : null

  instance_type  = local.bbb_type
  instance_count = local.bbb_count
  instance_size  = local.bbb_size

  hostname         = local.bbb_hostname
  hostname_pattern = local.bbb_hostname_pattern
  domain           = local.domain

  iam_role        = local.bbb_iam_role
  ami_id          = local.bbb_ami_id
  ami_name_filter = local.bbb_ami_name_filter
  default_tags    = local.default_tags
  subnets         = module.vpc-data.subnet_ids
  email           = local.bbb_email

  secrets = { for k, v in local.bbb_secrets : format("%s.%s", k, local.domain) => v }

  security_groups = [
    module.sg.ssh_sg_id,
    module.sg.bbb_sg_id,
    module.sg.nfs_sg_id,
  ]

  ssh_user = local.ssh_user
  key_name = local.ssh_key_name
  key_file = local.ssh_key_file

  ssl_key_file = local.ssl_key_file
  ssl_crt_file = local.ssl_crt_file

  hostname_to_ip            = module.eip.hostname_to_ip
  hostname_to_allocation_id = module.eip.hostname_to_allocation_id

  depends_on = [module.vpc-data, module.sg, module.efs, module.eip]

}
