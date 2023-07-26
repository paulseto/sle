locals {
  hostnames = [for host in var.hostnames : format("%s.%s", host, var.domain)]
}

resource "aws_eip" "this" {
  for_each = toset(var.create ? local.hostnames : [])

  domain = "vpc"

  tags = merge(var.default_tags, {
    Name     = each.value
    Hostname = each.value
  })
}

data "aws_eip" "this" {
  for_each = toset(local.hostnames)
  filter {
    name   = "tag:Hostname"
    values = [each.value]
  }

  depends_on = [resource.aws_eip.this]
}
