locals {
  hostnames = var.instance_count == 1 ? [format("%s.%s", var.hostname, var.domain)] : [for i in range(0, var.instance_count) : format("%s.%s", format(var.hostname_pattern, var.hostname, i + 1), var.domain)]

  secrets = { for h in local.hostnames : h => lookup(var.secrets, h, resource.random_string.this[h].result) }
}

resource "aws_instance" "this" {
  for_each = toset(local.hostnames)

  ami                         = data.aws_ami.this.id
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_role
  instance_type               = var.instance_type
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

  # Connect and run a command to make sure an instance is ready
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
}

resource "random_string" "this" {
  for_each = toset(local.hostnames)

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

resource "local_file" "inv" {
  filename        = format(".bbb.inv.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    all = {
      hosts = { for k, v in resource.aws_instance.this : lookup(var.hostname_to_ip, k, v.public_ip) => {
        hostname                     = k
        ansible_user                 = var.ssh_user
        ansible_ssh_private_key_file = var.key_file
        secret                       = local.secrets[k]
      } }
    }
  })
  depends_on = [resource.aws_eip_association.this]
}

resource "local_file" "vars" {
  filename        = format(".bbb.vars.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    efs_dns : var.efs_dns
    email : var.email
    ssl_key_file : var.ssl_key_file
    ssl_crt_file : var.ssl_crt_file
  })

  depends_on = [resource.local_file.inv]
}

resource "local_file" "secrets" {
  filename        = format(".bbb.secrets.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    bbb_secrets : local.secrets
  })

  depends_on = [resource.local_file.inv]
}
