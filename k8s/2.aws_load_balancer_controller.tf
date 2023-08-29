
resource "kubernetes_service_account" "serviceaccount_aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.role_aws_load_balancer_controller[count.index].arn
      # "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
  # secret {}
  secret {
    name = kubernetes_secret.secret_aws_load_balancer_controller.metadata.0.name
  }
  automount_service_account_token = true
}

resource "kubernetes_secret" "secret_aws_load_balancer_controller" {
  metadata {
    name = "aws-load-balancer"
  }
}

resource "aws_iam_role" "role_aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  name  = "role-aws-load-balancer-controller-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_aws_load_balancer_controller.json
  managed_policy_arns = [
    aws_iam_policy.policy_aws_load_balancer_controller[count.index].arn
  ]
}

resource "aws_iam_policy" "policy_aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  name  = "policy-aws-load-balancer-controller-${var.tag_common}"

  path   = "/"
  policy = file("${path.module}/files/policy_aws_load_balancer_controller.json")
}

resource "aws_ec2_tag" "tag_public_aws_load_balancer_controller" {
  count = length(var.subnet_public_ids)

  resource_id = var.subnet_public_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = 1
}

resource "aws_ec2_tag" "tag_private_aws_load_balancer_controller" {
  count = length(var.subnet_private_ids)

  resource_id = var.subnet_private_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = 1
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.serviceaccount_aws_load_balancer_controller[0],
    aws_ec2_tag.tag_public_aws_load_balancer_controller,
    aws_ec2_tag.tag_private_aws_load_balancer_controller
  ]

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster.name
  }
}
