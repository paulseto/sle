data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = var.ami_id == null ? "name" : "image-id"
    values = [var.ami_id == null ? var.ami_name_filter : var.ami_id]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

}

data "aws_route53_zone" "this" {
  name = var.domain
}
