locals {
  cluster_name = "clst-${var.tag_common}"
}

resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.role_cluster.arn
  version  = lookup(var.eks, "version", "1.25")

  vpc_config {
    endpoint_private_access = lookup(var.eks, "endpoint_private_access", true)
    endpoint_public_access  = lookup(var.eks, "endpoint_public_access", true)
    # security_group_ids      = lookup(var.eks, "security_group_ids", [])
    security_group_ids = [aws_security_group.securitygroup_cluster.id]
    subnet_ids         = var.subnet_private_ids
  }

  enabled_cluster_log_types = lookup(var.eks, "enabled_cluster_log_types", [])
}

resource "aws_eks_addon" "addon" {
  for_each = var.eks.addons

  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = each.key

  addon_version               = lookup(each.value, "addon_version", data.aws_eks_addon_version.latest[each.key].version)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)
  resolve_conflicts_on_update = lookup(each.value, "resolve_conflicts_on_update", "PRESERVE")
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.certificate.certificates.0.sha1_fingerprint]
}

resource "aws_iam_role" "role_cluster" {
  name = "role-eksclst-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_cluster.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
}

resource "aws_security_group" "securitygroup_cluster" {
  name = "sg_eksclst-${var.tag_common}"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                        = "sg-eksclst-${var.tag_common}"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "aws:eks:cluster-name"                        = "${local.cluster_name}"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# resource "aws_ec2_tag" "tag_eks_securitygroup_1" {
#   resource_id = aws_security_group.securitygroup_cluster.id
#   key         = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
#   value       = "owned"
# }

# resource "aws_ec2_tag" "tag_eks_securitygroup_2" {
#   resource_id = aws_security_group.securitygroup_cluster.id
#   key         = "aws:eks:cluster-name"
#   value       = "${aws_eks_cluster.cluster.name}"
# }

resource "aws_ec2_tag" "tag_eks_subnet" {
  count = length(concat(var.subnet_public_ids, var.subnet_private_ids))

  resource_id = concat(var.subnet_public_ids, var.subnet_private_ids)[count.index]
  key         = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
  value       = "shared"
}
