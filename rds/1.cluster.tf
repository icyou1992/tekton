locals {
  cluster_name = "clst-${var.tag_common}"
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier = local.cluster_name

  engine = lookup(var.rds, "engine", "aurora-mysql")
  engine_version = lookup(var.rds, "engine_version", "5.7.mysql_aurora.2.11.2")
  # db_cluster_instance_class = lookup(var.rds, "db_cluster_instance_class", "db.t4g.medium")

  availability_zones = lookup(var.rds, "availability_zones", ["ap-northeast-2a", "ap-northeast-2b"])
  database_name = lookup(var.rds, "database_name", "demo")
  master_username = lookup(var.rds, "master_username", "admin")
  master_password = lookup(var.rds, "master_password", "QWERqwer12#")

  backup_retention_period = lookup(var.rds, "backup_retention_period", 1)

  db_subnet_group_name = lookup(var.rds, "db_subnet_group_name", null)
  # allocated_storage = lookup(var.rds, "allocated_storage", 100)

  skip_final_snapshot = lookup(var.rds, "skip_final_snapshot", true)
  final_snapshot_identifier = lookup(var.rds, "final_snapshot_identifier", null)
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = lookup(var.rds, "count", 1)
  identifier         = "${local.cluster_name}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = lookup(var.rds, "instance_class", "db.t3.small")
  engine             = aws_rds_cluster.cluster.engine
  engine_version     = aws_rds_cluster.cluster.engine_version
}