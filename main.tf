locals {
  id     = "pfe"
  env    = "dev"
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
      cidrsubnet("10.0.0.0/20", 4, 2) 
    ]
  }

  subnet_private = {
    cidr = [
      cidrsubnet("10.0.0.0/20", 4, 3),
      cidrsubnet("10.0.0.0/20", 4, 4)
    ]
    azs = [
      "ap-northeast-2a",
      "ap-northeast-2c",
    ]
  }
}

module "eks" {
  source = "./eks"
  # depends_on = [ module.vpc ]

  # local.common으로 variable을 넘기면 role, launch template name 생성 과정에서 동적 할당이라 validate error가 발생하는 것으로 보임
  # tag_common = local.common
  tag_common = "pfe-dev"

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids

  eks = {
    version       = "1.26"
    instance_type = "t3.medium"
    key           = "pfe"

    block_device_mappings = {}

    addons = {
      coredns = {
        # addon_version     = "v1.9.3-eksbuild.2"
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {
        # addon_version     = "v1.25.6-eksbuild.2"
        resolve_conflicts = "OVERWRITE"
      }
      vpc-cni = {
        # addon_version     = "v1.12.2-eksbuild.1"
        resolve_conflicts = "OVERWRITE"
      }
      # aws-ebs-csi-driver = {
      #   resolve_conflicts = "OVERWRITE"
      #   service_account_role_arn = 
      # }
    }
  }
}

module "k8s" {
  source = "./k8s"
  # depends_on = [ module.eks ]

  tag_common = "pfe-dev"
  cluster    = module.eks.cluster

  vpc_id             = module.vpc.vpc_id
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids

  enable_aws_ebs_csi_driver           = true
  enable_aws_load_balancer_controller = true

  # k8s = {
  #   name = "game-2048"
  # }
}


