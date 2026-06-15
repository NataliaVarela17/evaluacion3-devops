output "cluster_name" {
  description = "Nombre del clúster EKS"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint del clúster EKS"
  value       = aws_eks_cluster.eks.endpoint
}

output "backend_despachos_ecr_url" {
  description = "URL del repositorio ECR para el backend de despachos"
  value       = aws_ecr_repository.backend_despachos.repository_url
}

output "backend_ventas_ecr_url" {
  description = "URL del repositorio ECR para el backend de ventas"
  value       = aws_ecr_repository.backend_ventas.repository_url
}

output "frontend_ecr_url" {
  description = "URL del repositorio ECR para el frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "eks_cluster_sg_id" {
  description = "ID del Security Group del clúster EKS"
  value       = aws_security_group.eks_cluster_sg.id
}

output "eks_nodes_sg_id" {
  description = "ID del Security Group de los nodos workers"
  value       = aws_security_group.eks_nodes_sg.id
}
