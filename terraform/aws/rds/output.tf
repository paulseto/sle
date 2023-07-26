output "reader_endpoint" {
  value = var.create ? resource.aws_rds_cluster.this[0].reader_endpoint : "db"
}
output "endpoint" {
  value = var.create ? resource.aws_rds_cluster.this[0].endpoint : "db"
}
output "database_name" {
  value = local.db_name
}
output "master_password" {
  value = local.db_password
}
output "master_username" {
  value = var.root_username
}
output "port" {
  value = var.create ? resource.aws_rds_cluster.this[0].port : 5432
}
