module "eip" {
  source = "../../terraform/aws/eip"

  create       = local.eip_create
  hostnames    = local.eip_hostnames
  domain       = local.domain
  default_tags = local.default_tags
}
