# output "dns" {
#   value = var.create ? resource.aws_elasticache_replication_group.this : null
# }
output "primary_endpoint" {
  value = var.create ? resource.aws_elasticache_replication_group.this[0].primary_endpoint_address : "cache"
}
output "reader_endpoint" {
  value = var.create ? resource.aws_elasticache_replication_group.this[0].reader_endpoint_address : "cache"
}
