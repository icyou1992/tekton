locals {
  oidc = trimprefix("${var.cluster.identity[0].oidc[0].issuer}", "https://")
}