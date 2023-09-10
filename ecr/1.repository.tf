locals {
  repository_name = "ecr-${var.tag_common}"
}

resource "aws_ecr_repository" "repository" {
  name                 = local.repository_name
  image_tag_mutability = lookup(var.ecr, "image_tag_mutability", "MUTABLE")
  force_delete         = lookup(var.ecr, "force_delete", true)

  image_scanning_configuration {
    scan_on_push = lookup(var.ecr, "scan_on_push", true)
  }
}
