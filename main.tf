locals {
  id = " pfe"
  env = "dev"
  common = "${local.id}-${local.env}"
}

module "vpc" {
  source = "./vpc"

  tag_common = local.common
  
  vpc = {
    cidr = "10.0.0.0/20"
  }

  subnet_public = {
    cidr = [ cidrsubnet("10.0.0.0/20", 4, 1), cidrsubnet("10.0.0.0/20", 4, 2) ]
  }

  subnet_private = {
    cidr = [ cidrsubnet("10.0.0.0/20", 4, 3), cidrsubnet("10.0.0.0/20", 4, 4) ]
  }
}