output "cluster" {
  value = aws_eks_cluster.cluster
}

output "node_group_name" {
  value = aws_eks_node_group.nodegroup.node_group_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}