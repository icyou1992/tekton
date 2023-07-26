data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_ebs_default_kms_key" "current" {}

data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = var.cluster.name
}
# data "aws_eks_cluster" "cluster" {
#   name = var.cluster.name
# }

data "aws_eks_addon_version" "latest_ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster.version
  most_recent        = true
}

data "aws_iam_policy_document" "policy_assume_role_ebs_csi_driver" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc}"]
    }

    condition {
      test = "StringEquals"
      variable = "${local.oidc}:sub"
      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}
data "aws_iam_policy_document" "policy_assume_role_aws_load_balancer_controller" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc}"]
    }

    condition {
      test = "StringEquals"
      variable = "${local.oidc}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}
