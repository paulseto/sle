output "dns_name" {
  value = var.create ? resource.aws_efs_file_system.this[0].dns_name : ""
}
