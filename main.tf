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
    cidr = [ 
      cidrsubnet("10.0.0.0/20", 4, 1), 
      # cidrsubnet("10.0.0.0/20", 4, 2) 
    ]
  }

  subnet_private = {
    cidr = [ 
      cidrsubnet("10.0.0.0/20", 4, 3), 
      # cidrsubnet("10.0.0.0/20", 4, 4) 
    ]
  }
}

module "eks" {
  source = "./eks"

  tag_common = local.common

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_private_ids
  
}