resource "aws_elasticache_replication_group" "this" {
  count = var.create ? 1 : 0

  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = var.availability_zones
  replication_group_id        = var.prefix
  description                 = format("Scalelite server pool for %s", var.prefix)
  node_type                   = var.instance_type
  num_cache_clusters          = length(var.availability_zones)
  parameter_group_name        = var.parameter_group
  port                        = 6379
  security_group_ids          = var.security_group_ids
  subnet_group_name           = resource.aws_elasticache_subnet_group.this[0].name
  tags                        = var.tags

  lifecycle {
    ignore_changes = [num_cache_clusters]
  }

  depends_on = [
    resource.aws_elasticache_subnet_group.this
  ]
}

resource "aws_elasticache_subnet_group" "this" {
  count      = var.create ? 1 : 0
  name       = format("%s-cache-subnet-group", var.prefix)
  subnet_ids = var.subnet_ids
}
