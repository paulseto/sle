output "instances" {
  value = {
    for k, v in resource.aws_instance.this : k => {
      eip = lookup(var.hostname_to_ip, k, null)
      ip  = v.public_ip
    }
  }
}
output "ami" {
  value = {
    id               = data.aws_ami.this.id
    creation_date    = data.aws_ami.this.creation_date
    deprecation_time = data.aws_ami.this.deprecation_time
    description      = data.aws_ami.this.description
  }
}
