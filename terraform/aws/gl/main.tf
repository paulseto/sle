locals {
  hostnames      = var.instance_count == 1 ? [format("%s.%s", var.hostname, var.domain)] : [for i in range(0, var.instance_count) : format("%s.%s", format(var.hostname_pattern, var.hostname, i + 1), var.domain)]
  admin_password = coalesce(var.admin_password, resource.random_string.admin_password.result)
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

  root_block_device {
    volume_size = var.instance_size
    volume_type = "gp3"
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
  filename        = format(".gl.inv.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    all = {
      hosts = { for k, v in resource.aws_instance.this : lookup(var.hostname_to_ip, k, v.public_ip) => {
        hostname                     = k
        ansible_user                 = var.ssh_user
        ansible_ssh_private_key_file = var.key_file
      } }
    }
  })
  depends_on = [resource.aws_eip_association.this]
}

resource "local_file" "vars" {
  filename        = format(".gl.vars.%s.yml", terraform.workspace)
  file_permission = "0644"
  content = yamlencode({
    ssl_key_file : var.ssl_key_file
    ssl_crt_file : var.ssl_crt_file
    sl_hostname : var.sl_hostname
    sl_secret : var.sl_secret
    admin_name : var.admin_name
    admin_password : local.admin_password
    admin_email : var.admin_email
  })

  depends_on = [resource.local_file.inv]
}

resource "random_string" "admin_password" {
  length = 20
}
