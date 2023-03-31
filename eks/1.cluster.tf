resource "aws_eks_cluster" "cluster" {
  name     = "clst-${var.tag_common}"
  role_arn = aws_iam_role.role_cluster.arn
  version  = lookup(var.eks, "version", "1.26")

  vpc_config {
    endpoint_private_access = lookup(var.eks, "endpoint_private_access", true)
    endpoint_public_access  = lookup(var.eks, "endpoint_public_access", true)
    security_group_ids      = []
    subnet_ids              = var.subnet_ids
  }
}

# resource "aws_security_group" "name" {
#   name = "sg_eksclst-${var.tag_common}"
#   vpc_id = var.vpc_id

#   tags = {
#     Name = "sg-eksclst-${var.tag_common}"
#   }
# }

resource "aws_eks_addon" "addon" {
  for_each = merge({
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    # ebs-csi-controller = {
    #   resolve_conflicts = "OVERWRITE"
    #   service_account_role_arn = ""
    # }
  }, var.eks.addons)

  cluster_name = aws_eks_cluster.cluster.name
  addon_name = each.key

  addon_version = each.value.addon_version
  resolve_conflicts = each.value.resolve_conflicts
  service_account_role_arn = each.value.service_account_role_arn
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.tls_certificate.certificate.url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [ data.tls_certificate.certificate.certificates.0.sha1_fingerprint ]
}

resource "aws_iam_role" "role_cluster" {
  name = "role-eksclst-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_cluster
  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",

  ]
}