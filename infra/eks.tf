# ─── Clúster EKS ──────────────────────────────────────────────────────────────
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_1.id,
      aws_subnet.eks_subnet_2.id
    ]
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table_association.rta_1,
    aws_route_table_association.rta_2,
    aws_security_group.eks_cluster_sg,
    aws_security_group.eks_nodes_sg
  ]
}

# ─── Node Group (workers) ─────────────────────────────────────────────────────
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "workers"
  node_role_arn   = data.aws_iam_role.labrole.arn

  subnet_ids = [
    aws_subnet.eks_subnet_1.id,
    aws_subnet.eks_subnet_2.id
  ]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_eks_cluster.eks]

  # IMPORTANTE: Al destruir el node group, primero hay que eliminar
  # los recursos de Kubernetes (kubectl delete -f k8s/) para que
  # el LoadBalancer libere las IPs públicas antes de que Terraform
  # intente eliminar las subnets y el Internet Gateway.
  lifecycle {
    create_before_destroy = false
  }
}
