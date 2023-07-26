module "http" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 5"

  vpc_id      = var.vpc_id
  name        = format("%s-http", var.prefix)
  description = format("http access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-http", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = []
}

module "https" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "~> 5"

  vpc_id      = var.vpc_id
  name        = format("%s-https", var.prefix)
  description = format("https access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-https", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = []
}

module "nfs" {
  source  = "terraform-aws-modules/security-group/aws//modules/nfs"
  version = "5.1.0"

  create      = var.create_efs
  vpc_id      = var.vpc_id
  name        = format("%s-nfs", var.prefix)
  description = format("nfs access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-nfs", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = var.subnet_cidr_blocks
  egress_ipv6_cidr_blocks = []
}

module "cache" {
  source  = "terraform-aws-modules/security-group/aws//modules/redis"
  version = "5.1.0"

  create      = var.create_cache
  vpc_id      = var.vpc_id
  name        = format("%s-cache", var.prefix)
  description = format("cache access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-cache", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = var.subnet_cidr_blocks
  egress_ipv6_cidr_blocks = []
}

module "db" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "5.1.0"

  create      = var.create_db
  vpc_id      = var.vpc_id
  name        = format("%s-db", var.prefix)
  description = format("db access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-db", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = var.subnet_cidr_blocks
  egress_ipv6_cidr_blocks = []
}

module "ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5"

  vpc_id      = var.vpc_id
  name        = format("%s-ssh", var.prefix)
  description = format("ssh access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-ssh", var.prefix) })

  auto_ingress_with_self  = []
  ingress_cidr_blocks     = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = []
}

module "turn" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  vpc_id      = var.vpc_id
  name        = format("%s-turn", var.prefix)
  description = format("turn access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-turn", var.prefix) })

  ingress_with_cidr_blocks = [
    {
      from_port   = 3478
      to_port     = 3478
      protocol    = "tcp"
      description = format("turn access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "All protocols"
    }
  ]
}

module "webrtc" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  vpc_id      = var.vpc_id
  name        = format("%s-webrtc", var.prefix)
  description = format("webrtc access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-webrtc", var.prefix) })

  ingress_with_cidr_blocks = [
    {
      from_port   = 16384
      to_port     = 32768
      protocol    = "udp"
      description = format("webrtc access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "All protocols"
    }
  ]
}

module "bbb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  vpc_id      = var.vpc_id
  name        = format("%s-bbb", var.prefix)
  description = format("bbb access for %s", var.prefix)
  tags        = merge(var.default_tags, { Name = format("%s-bbb", var.prefix) })

  ingress_with_cidr_blocks = [
    {
      from_port   = 16384
      to_port     = 32768
      protocol    = "udp"
      description = format("webrtc access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = format("http access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = format("http access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3278
      to_port     = 3278
      protocol    = "tcp"
      description = format("turn access for %s", var.prefix)
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
      description = "All protocols"
    }
  ]
}
data "aws_vpc" "this" {
  id = var.vpc_id
}
