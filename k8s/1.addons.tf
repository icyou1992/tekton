resource "aws_eks_addon" "addon_ebs_csi_driver" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0

  cluster_name = var.cluster.name
  addon_name   = "aws-ebs-csi-driver"

  addon_version            = data.aws_eks_addon_version.latest_ebs_csi_driver.version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.role_ebs_csi_driver[count.index].arn
}

resource "aws_iam_role" "role_ebs_csi_driver" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0
  name = "role-ebs-csi-driver-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_kubernetes.json
  managed_policy_arns = [
    aws_iam_policy.policy_ebs_csi_driver[count.index].arn,
    aws_iam_policy.policy_ebs_csi_driver_kms[count.index].arn
  ]
}

resource "aws_iam_policy" "policy_ebs_csi_driver" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0
  name = "policy-ebs-csi-driver-${var.tag_common}"

  path = "/"
  policy = file("${path.module}/files/policy_ebs_csi_driver.json")
}

resource "aws_iam_policy" "policy_ebs_csi_driver_kms" {
  count = var.enable_aws_ebs_csi_driver ? 1 : 0
  name = "policy-ebs-csi-driver-kms-${var.tag_common}"

  path = "/"
  policy = templatefile("${path.module}/files/policy_ebs_csi_driver_kms.json.tpl", {
    kms_key_arn = var.encryption_key != null ? var.encryption_key : data.aws_ebs_default_kms_key.current.key_arn
  })
}

# resource "kubernetes_service_account" "serviceaccount_aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
#   metadata {
#     name = "sa-aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name" = "sa-aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "csi-driver"
#       "app.kubernetes.io/managed-by" = "EKS"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.role_ebs_csi_driver.arn
#     }
#   }
# }

# resource "aws_iam_role" "role_aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
#   name = "role-aws-load-balancer-controller-${var.tag_common}"

#   assume_role_policy = data.aws_iam_policy_document.policy_assume_role_kubernetes.json
#   managed_policy_arns = [
#     aws_iam_policy.policy_aws_load_balancer_controller.arn
#   ]
# }

# resource "aws_iam_policy" "policy_aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
#   name = "policy-aws-load-balancer-controller-${var.tag_common}"

#   path = "/"
#   policy = file("${path.module}/files/policy_aws_load_balancer_controller.json")
# }
