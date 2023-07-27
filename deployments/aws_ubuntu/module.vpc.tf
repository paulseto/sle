module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  create_vpc = local.vpc_create
  cidr       = local.vpc_cidr
  azs        = [for az in local.vpc_azs : format("%s%s", local.aws_region, az)]
  vpc_tags   = local.default_tags

  public_subnets      = [for i, v in local.vpc_azs : cidrsubnet(local.vpc_cidr, local.vpc_bits, i + 1)]
  public_subnet_names = [for v in local.vpc_azs : format("%s-public-%s", local.prefix, v)]

}
