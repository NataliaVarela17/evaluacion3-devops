# ─── Referencia al LabRole de AWS Academy ────────────────────────────────────
# AWS Academy no permite crear roles IAM propios, por eso se usa el LabRole
# que ya existe en la cuenta y tiene los permisos necesarios para EKS.
#
# El LabRole cumple los siguientes roles en el proyecto:
#   - EKS Cluster Role:    permite al plano de control de EKS gestionar recursos AWS
#   - EKS Node Role:       permite a los nodos EC2 unirse al clúster y descargar imágenes ECR
#   - ECS Task Role:       permite a los contenedores acceder a servicios AWS (ECR, CloudWatch)
#   - ECS Execution Role:  permite a ECS descargar imágenes y enviar logs a CloudWatch

data "aws_iam_role" "labrole" {
  name = "LabRole"
}

# ─── Referencia a la política del LabRole ─────────────────────────────────────
data "aws_iam_policy" "lab_policy" {
  name = "AdministratorAccess"
}

# ─── Output del ARN del rol para referencia ───────────────────────────────────
output "labrole_arn" {
  description = "ARN del LabRole usado por EKS y los nodos workers"
  value       = data.aws_iam_role.labrole.arn
}
