output "instances" {
  value = {
    for k, v in resource.aws_instance.this : k => {
      eip = var.hostname_to_ip[k]
      ip  = v.public_ip
    }
  }
}
output "secret_key_base" {
  value     = resource.random_string.secret_key_base.result
  sensitive = true
}
output "hostname" {
  value = format("%s.%s", var.hostname, var.domain)
}
output "secret" {
  value     = local.load_balancer_secret
  sensitive = true
}
