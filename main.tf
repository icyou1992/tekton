locals {
  id     = "pfe"
  env    = "dev"
  common = "${local.id}-${local.env}"

  cidr = "10.0.0.0/20"
  key = "key-pfe"
}

module "vpc" {
  source = "./vpc"

  tag_common = local.common

  vpc = {
    cidr = local.cidr
  }

  subnet_public = {
    cidr = [
      cidrsubnet(local.cidr, 4, 1),
      # cidrsubnet(local.cidr, 4, 2) 
    ]
  }

  subnet_private = {
    cidr = [
      cidrsubnet(local.cidr, 4, 3),
      cidrsubnet(local.cidr, 4, 4)
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
  tag_common = local.common

  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_public_ids  = module.vpc.subnet_public_ids
  subnet_private_ids = module.vpc.subnet_private_ids

  eks = {
    version       = "1.27"
    instance_type = "t3.medium"
    key           = local.key

    block_device_mappings = [{
      device_name = "/dev/xvda"
      ebs = [{
        volume_size = 10
        volume_type = "gp3"
        encrypted = true
        kms_key_id = data.aws_ebs_default_kms_key.current.key_arn
      }]
    }]

    addons = {
      coredns = {
        # addon_version     = "v1.9.3-eksbuild.2"
        resolve_conflicts_on_update = "OVERWRITE"
      }
      kube-proxy = {
        # addon_version     = "v1.25.6-eksbuild.2"
        resolve_conflicts_on_update = "OVERWRITE"
      }
      vpc-cni = {
        # addon_version     = "v1.12.2-eksbuild.1"
        resolve_conflicts_on_update = "OVERWRITE"
      }
      # aws-ebs-csi-driver = {
      #   resolve_conflicts_on_update = "OVERWRITE"
      #   service_account_role_arn = 
      # }
    }
  }
}

module "k8s" {
  source = "./k8s"
  # depends_on = [ module.eks ]

  tag_common = local.common
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


