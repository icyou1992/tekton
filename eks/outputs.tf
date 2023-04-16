output "cluster" {
  value = aws_eks_cluster.cluster
}

output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "node_group_name" {
  value = aws_eks_node_group.nodegroup.node_group_name
}
