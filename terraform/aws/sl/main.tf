locals {
  hostname  = format("%s.%s", var.hostname, var.domain)
  hostnames = var.instance_count == 1 ? [local.hostname] : [for i in range(0, var.instance_count) : format("%s.%s", format(var.hostname_pattern, var.hostname, i + 1), var.domain)]

  load_balancer_secret = coalesce(var.lb_secret, resource.random_string.load_balancer_secret.result)

  tenants = { for k, v in var.tenants : format("%s.%s", k, local.hostname) => v }
}

resource "aws_instance" "this" {
  for_each = toset(local.hostnames)

  ami                         = data.aws_ami.this.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_role
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnets[index(local.hostnames, each.value) % length(var.subnets)]
  hibernation                 = true

  root_block_device {
    volume_size = var.instance_size
    volume_type = "gp3"
    encrypted   = true
    tags        = merge(var.default_tags, { Hostname = each.value })
  }

  tags = merge(var.default_tags, {
    Name     = each.value
    Hostname = each.value
  })

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.key_file)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${each.value}"
    ]
  }
}

resource "aws_eip_association" "this" {
  for_each = setintersection(local.hostnames, keys(var.hostname_to_allocation_id))

  instance_id   = resource.aws_instance.this[each.value].id
  allocation_id = var.hostname_to_allocation_id[each.value]

  depends_on = [
    resource.aws_instance.this
  ]
}

resource "random_string" "this" {
  length  = 64
  lower   = true
  special = false
}

resource "random_string" "secret_key_base" {
  length  = 64
  lower   = true
  special = false
}

resource "random_string" "load_balancer_secret" {
  length  = 32
  lower   = true
  special = false
}

resource "aws_route53_record" "this" {
  for_each = resource.aws_instance.this

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.tags["Name"]
  type    = "A"
  ttl     = "300"
  records = [lookup(var.hostname_to_ip, each.key, each.value.public_ip)]

  depends_on = [resource.aws_eip_association.this]
}

resource "aws_route53_record" "round-robin" {
  count = var.instance_count == 1 ? 0 : 1

  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.hostname
  type    = "A"
  ttl     = "300"
  records = [for k, v in resource.aws_instance.this : lookup(var.hostname_to_ip, k, v.public_ip)]
}

resource "aws_route53_record" "tenants" {
  count = length(local.tenants) == 0 ? 0 : 1

  zone_id = data.aws_route53_zone.this.zone_id
  name    = format("*.%s", local.hostname)
  type    = "A"
  ttl     = "300"
  records = var.instance_count == 1 ? [lookup(var.hostname_to_ip, local.hostname, resource.aws_instance.this[local.hostname].public_ip)] : [for k, v in resource.aws_instance.this : lookup(var.hostname_to_ip, k, v.public_ip)]
}

resource "local_file" "inv" {
  filename        = format(".sl.inv.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    all = {
      hosts = { for k, v in resource.aws_instance.this : lookup(var.hostname_to_ip, k, v.public_ip) => {
        hostname                     = k
        ansible_user                 = var.ssh_user
        ansible_ssh_private_key_file = var.key_file
        primary                      = index(local.hostnames, k) == 0
      } }
    }
  })
  depends_on = [
    resource.aws_instance.this,
    resource.aws_eip_association.this
  ]
}

resource "local_file" "vars" {
  filename        = format(".sl.vars.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    efs_dns : var.efs_dns
    cache_dns : var.cache_dns
    cache_use_docker : var.cache_use_docker
    cache_docker_image : var.cache_docker_image
    db_dns : var.db_dns
    db_name : var.db_name
    db_root_username : var.master_username
    db_root_password : var.master_password
    db_use_docker : var.db_use_docker
    db_docker_image : var.db_docker_image
    lb_secret : local.load_balancer_secret
    secret_key_base : resource.random_string.secret_key_base.result
    scalelite_tag : var.sl_image_tag
    ssl_crt_file : var.ssl_crt_file
    ssl_key_file : var.ssl_key_file
    tenant_crt_file : var.tenant_crt_file
    tenant_key_file : var.tenant_key_file
    enable_tenants : var.enable_tenants
    tenants : local.tenants
  })
  depends_on = [resource.local_file.inv]
}
