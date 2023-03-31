data "aws_iam_policy_document" "policy_assume_role_kubernetes" {
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
      values = ["system:account:kube-system:aws-load-balancer-controller"]
    }
  }
}