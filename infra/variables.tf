variable "aws_region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "despacho-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR de la subred 1 (us-east-1a)"
  type        = string
  default     = "10.0.10.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR de la subred 2 (us-east-1b)"
  type        = string
  default     = "10.0.20.0/24"
}

variable "node_instance_type" {
  description = "Tipo de instancia para los nodos workers"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Cantidad deseada de nodos"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Máximo de nodos"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Mínimo de nodos"
  type        = number
  default     = 1
}
