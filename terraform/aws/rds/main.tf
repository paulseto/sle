locals {
  db_name     = replace(var.prefix, "-", "")
  db_password = coalesce(var.root_password, resource.random_string.this.result)
}
resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name       = var.prefix
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0

  cluster_identifier  = var.prefix
  engine              = var.engine
  engine_version      = var.engine_version
  availability_zones  = var.availability_zones
  database_name       = local.db_name
  master_username     = var.root_username
  master_password     = local.db_password
  skip_final_snapshot = true
  # backup_retention_period = 5
  # preferred_backup_window = "07:00-09:00"

  # cluster_identifier   = var.prefix
  # db_subnet_group_name = aws_db_subnet_group.this.name
  # engine_mode          = "multimaster"
  # master_password      = "barbarbarbar"
  # master_username      = "foo"
  # skip_final_snapshot  = true

  tags = var.tags
}

resource "random_string" "this" {
  length  = 20
  special = false
}

resource "aws_rds_cluster_instance" "this" {
  count = var.create ? var.instance_count : 0

  identifier         = format("%s-%d", var.prefix, count.index + 1)
  cluster_identifier = resource.aws_rds_cluster.this[0].id
  instance_class     = var.instance_type
  engine             = var.engine
  engine_version     = var.engine_version

  tags = var.tags
}
