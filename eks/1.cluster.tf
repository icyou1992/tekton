resource "aws_eks_cluster" "cluster" {
  name     = "clst-${var.tag_common}"
  role_arn = aws_iam_role.role_cluster.arn
  version  = lookup(var.eks, "version", "1.25")

  vpc_config {
    endpoint_private_access = lookup(var.eks, "endpoint_private_access", true)
    endpoint_public_access  = lookup(var.eks, "endpoint_public_access", true)
    # security_group_ids      = lookup(var.eks, "security_group_ids", [])
    security_group_ids      = [ aws_security_group.securitygroup_cluster.id ]
    subnet_ids              = var.subnet_ids
  }
  
  enabled_cluster_log_types = lookup(var.eks, "enabled_cluster_log_types", [])
}

resource "aws_eks_addon" "addon" {
  for_each = var.eks.addons

  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = each.key

  addon_version            = lookup(each.value, "addon_version", data.aws_eks_addon_version.latest[each.key].version)
  resolve_conflicts        = lookup(each.value, "resolve_conflicts", null)
  service_account_role_arn = lookup(each.value, "service_account_role_arn", null)
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.tls_certificate.certificate.url
  client_id_list  = [ "sts.amazonaws.com" ]
  thumbprint_list = [ data.tls_certificate.certificate.certificates.0.sha1_fingerprint ]
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
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr ]
  }
  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr ]
  }
  ingress {
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    cidr_blocks = [ var.vpc_cidr ]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#   tags = {
#     "Name" = "sg-eksclst-${var.tag_common}"
#     # "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "owned"
#     # "aws:eks:cluster-name" = "${aws_eks_cluster.cluster.name}"
#   }
# }
