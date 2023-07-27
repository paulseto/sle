# module "efs" {
#   source  = "terraform-aws-modules/efs/aws"
#   version = "1.2.0"

#   name      = local.prefix
#   encrypted = true

#   mount_targets = { for k, v in module.vpc-data.azs_to_subnets : k =>
#     {
#       subnet_id = v
#     }
#   }

#   security_group_vpc_id      = module.vpc-data.vpc_id
#   security_group_description = format("efs for %s", local.prefix)
#   security_group_rules = {
#     vpc = {
#       description = format("efs ingress from %s private subnets", local.prefix)
#       cidr_blocks = module.vpc-data.subnet_cidr_blocks
#     }
#   }

#   # access_points = {
#   #   bbb = {
#   #     name = "bbb"
#   #     posix_user = {
#   #       uid = 996
#   #       gid = 996
#   #     }
#   #   }
#   # }

#   enable_backup_policy = false
#   create_backup_policy = false

#   tags = merge(local.default_tags, { Name = local.prefix })
# }


module "efs" {
  source = "../../terraform/aws/efs"

  prefix          = local.prefix
  default_tags    = local.default_tags
  create          = local.efs_create
  subnet_ids      = module.vpc-data.subnet_ids
  iam_roles       = distinct([local.bbb_iam_role, local.sl_iam_role])
  security_groups = [module.sg.nfs_sg_id]

  depends_on = [
    module.vpc-data,
    module.sg
  ]
}
