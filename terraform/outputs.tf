output "cluster_id" {
  description = "EKS cluster id"
  value       = aws_eks_cluster.test.id
}

output "vpc_id" {
  description = "EKS VPC id"
  value       = aws_vpc.main.id
}

output "nodes_id" {
  description = "EKS worker nodes id"
  value       = aws_eks_node_group.private-nodes.id
}