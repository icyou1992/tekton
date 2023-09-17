resource "aws_db_instance" "db_instance" {
  identifier = "db-${var.tag_common}"
  db_name = lookup(var.rds, "db_name", "demo")

  engine = lookup(var.rds, "engine", "mysql")
  engine_version = lookup(var.rds, "engine_version", "5.7")
  instance_class = lookup(var.rds, "instance_class", "db.t3.micro")
  parameter_group_name = lookup(var.rds, "parameter_group_name", "default.mysql5.7")

  username = lookup(var.rds, "username", "pfe")
  password = lookup(var.rds, "password", "test123!")

  backup_retention_period = lookup(var.rds, "backup_retention_period", 0)

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  allocated_storage = lookup(var.rds, "allocated_storage", 30)

  skip_final_snapshot = lookup(var.rds, "skip_final_snapshot", true)
  final_snapshot_identifier = lookup(var.rds, "final_snapshot_identifier", null)
  auto_minor_version_upgrade = lookup(var.rds, "auto_minor_version_upgrade", false)

  
publicly_accessible = lookup(var.rds, "publicly_accessible", true)
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "sbng-${var.tag_common}"
  subnet_ids = data.aws_subnets.subnets.ids
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [ data.aws_vpc.vpc.id ]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["vpc-${var.tag_common}"]
  }
}