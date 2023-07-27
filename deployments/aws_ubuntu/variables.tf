locals {
  vars = yamldecode(file("vars.${terraform.workspace}.yml"))

  prefix           = format("%s-%s", local.vars["prefix"], terraform.workspace)
  domain           = local.vars["domain"]
  email            = lookup(local.vars, "email", null)
  hostname_pattern = lookup(local.vars, "hostname_pattern", "%s%d")
  ami_name_filter  = lookup(local.vars, "ami_name_filter", "buntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*")
  ami_id           = lookup(local.vars, "ami_id", null)
  iam_role         = lookup(local.vars, "iam_role", null)

  aws         = lookup(local.vars, "aws", {})
  aws_region  = local.aws["region"]
  aws_profile = lookup(local.aws, "profile", "default")

  eip           = lookup(local.vars, "eip", {})
  eip_create    = lookup(local.eip, "create", false)
  eip_hostnames = lookup(local.eip, "hostnames", [])


  vpc             = lookup(local.vars, "vpc", {})
  vpc_id          = lookup(local.vpc, "id", null)
  vpc_cidr        = lookup(local.vpc, "cidr", null)
  vpc_bits        = lookup(local.vpc, "bits", 8)
  vpc_azs         = lookup(local.vpc, "az", ["a", "b"])
  vpc_create      = local.vpc_id == null && local.vpc_cidr != null
  vpc_use_default = local.vpc_id == null && local.vpc_cidr == null

  efs        = lookup(local.vars, "efs", {})
  efs_create = lookup(local.efs, "create", false)

  bbb                  = lookup(local.vars, "bbb", {})
  bbb_type             = lookup(local.bbb, "type", "c5.4xlarge")
  bbb_count            = lookup(local.bbb, "count", 2)
  bbb_size             = lookup(local.bbb, "size", 50)
  bbb_hostname         = lookup(local.bbb, "hostname", "bbb")
  bbb_hostname_pattern = lookup(local.bbb, "hostname_pattern", local.hostname_pattern)
  bbb_iam_role         = lookup(local.bbb, "iam_role", local.iam_role)
  bbb_ami_name_filter  = lookup(local.bbb, "ami_name_filter", local.ami_name_filter)
  bbb_ami_id           = lookup(local.bbb, "ami_id", local.ami_id)
  bbb_email            = lookup(local.bbb, "email", local.email)
  bbb_secrets          = lookup(local.bbb, "secrets", {})

  cache                 = lookup(local.vars, "cache", {})
  cache_use_docker      = lookup(local.cache, "use_docker", false)
  cache_docker_image    = lookup(local.cache, "docker_image", null)
  cache_instance_type   = lookup(local.cache, "instance_type", "cache.t4g.micro")
  cache_instance_count  = lookup(local.cache, "instance_count", 2)
  cache_engine          = lookup(local.cache, "engine", "redis")
  cache_engine_version  = lookup(local.cache, "engine_version", "5.0.6")
  cache_parameter_group = lookup(local.cache, "parameter_group", "")

  db                 = lookup(local.vars, "db", {})
  db_docker_image    = lookup(local.db, "docker_image", null)
  db_use_docker      = lookup(local.db, "use_docker", false)
  db_engine          = lookup(local.db, "engine", "aurora-postgresql")
  db_engine_version  = lookup(local.db, "engine_version", "15.3")
  db_parameter_group = lookup(local.db, "parameter_group", "aurora-postgresql15")
  db_instance_type   = lookup(local.db, "instance_type", "db.t4g.micro")
  db_instance_count  = lookup(local.db, "instance_count", 2)
  db_root_username   = lookup(local.db, "root_username", "postgres")
  db_root_password   = lookup(local.db, "root_password", null)

  sl                  = lookup(local.vars, "sl", {})
  sl_type             = lookup(local.sl, "type", "t3.medium")
  sl_count            = lookup(local.sl, "count", 1)
  sl_size             = lookup(local.sl, "size", 20)
  sl_hostname         = lookup(local.sl, "hostname", "sl")
  sl_hostname_pattern = lookup(local.sl, "hostname_pattern", "%s%d")
  sl_iam_role         = lookup(local.sl, "iam_role", local.iam_role)
  sl_ami_name_filter  = lookup(local.sl, "ami_name_filter", local.ami_name_filter)
  sl_ami_id           = lookup(local.sl, "ami_id", local.ami_id)
  sl_lb_secret        = lookup(local.sl, "load_balancer_secret", null)
  sl_image_tag        = lookup(local.sl, "scalelite_tag", "v1.5-stable-focal260-alpine")
  sl_enable_tenants   = lookup(local.sl, "enable_tenants", false)
  sl_tenants          = lookup(local.sl, "tenants", {})
  sl_tenant_ssl       = lookup(local.sl, "tenant_ssl", {})
  sl_tenant_key_file  = lookup(local.sl_tenant_ssl, "key_file", null)
  sl_tenant_crt_file  = lookup(local.sl_tenant_ssl, "crt_file", null)

  gl                  = lookup(local.vars, "gl", {})
  gl_type             = lookup(local.gl, "type", "t3.medium")
  gl_count            = lookup(local.gl, "count", 1)
  gl_size             = lookup(local.gl, "size", 20)
  gl_hostname         = lookup(local.gl, "hostname", "gl")
  gl_hostname_pattern = lookup(local.gl, "hostname_pattern", "%s%d")
  gl_iam_role         = lookup(local.gl, "iam_role", local.iam_role)
  gl_ami_name_filter  = lookup(local.gl, "ami_name_filter", local.ami_name_filter)
  gl_ami_id           = lookup(local.gl, "ami_id", local.ami_id)
  gl_admin            = lookup(local.gl, "admin", {})
  gl_admin_email      = lookup(local.gl_admin, "email", null)
  gl_admin_password   = lookup(local.gl_admin, "password", null)
  gl_admin_name       = lookup(local.gl_admin, "name", null)

  ssh          = lookup(local.vars, "ssh", {})
  ssh_user     = local.ssh["user"]
  ssh_key_name = local.ssh["key_name"]
  ssh_key_file = local.ssh["key_file"]

  ssl          = lookup(local.vars, "ssl", {})
  ssl_key_file = lookup(local.ssl, "key_file", null)
  ssl_crt_file = lookup(local.ssl, "crt_file", null)

  default_tags = {
    Terraform = true
    Workspace = "${terraform.workspace}"
    Name      = local.prefix
    Location  = abspath(path.root)
  }
}
