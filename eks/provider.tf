provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.name]
  #   command     = "aws"
  # }
  token = data.aws_eks_cluster_auth.eks_auth.token
}