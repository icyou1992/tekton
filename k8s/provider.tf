provider "kubernetes" {
  host                   = var.cluster.endpoint
  cluster_ca_certificate = base64encode(var.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster.cluster_name]
    command     = "aws"
  }
}
