module "vpc-data" {
  source = "../../terraform/aws/vpc-data"

  vpc_id  = local.vpc_create ? module.vpc.vpc_id : local.vpc_id
  vpc_azs = [for z in local.vpc_azs : format("%s%s", local.aws_region, z)]

  depends_on = [ module.vpc ]
}
