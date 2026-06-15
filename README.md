# Evaluación Parcial N°3 — Orquestación con EKS

## Arquitectura

```
Internet
    │
    ▼
[LoadBalancer AWS] ──► [Frontend pod] ──► [backend-despachos pods (x2)]
                                      └──► [backend-ventas pods (x2)]
                                                      │
                                                  [MySQL pod]
                                               (ClusterIP - interno)
```

Solo el **Frontend** es accesible desde Internet. Los backends y MySQL viven en red interna del clúster.

---

## Estructura del proyecto

```
├── evaluacion2/                       # Código fuente (EP2)
│   ├── front_despacho/                # Frontend React + Dockerfile
│   ├── back-Despachos_SpringBoot/     # Backend Despachos + Dockerfile
│   └── back-Ventas_SpringBoot/        # Backend Ventas + Dockerfile
├── infra/                             # Infraestructura Terraform
│   ├── main.tf                        # Provider AWS
│   ├── variables.tf                   # Variables configurables
│   ├── networking.tf                  # VPC, subnets, IGW, route tables
│   ├── security-groups.tf             # Security Groups del clúster y nodos
│   ├── iam.tf                         # Roles IAM (LabRole)
│   ├── eks.tf                         # Clúster EKS y node group
│   ├── ecr.tf                         # Repositorios ECR (3 imágenes)
│   ├── cloudwatch.tf                  # Log groups de CloudWatch
│   └── outputs.tf                     # Outputs útiles post-apply
├── k8s/                               # Manifests Kubernetes
│   ├── mysql.yml                      # MySQL + Secret
│   ├── backend-despachos.yml          # Deployment + Service
│   ├── backend-ventas.yml             # Deployment + Service
│   ├── frontend.yml                   # Deployment + LoadBalancer
│   ├── hpa.yml                        # Autoscaling (HPA) de los 3 servicios
│   ├── cloudwatch.yml                 # Configuración de logs en CloudWatch
│   └── load-test.sh                   # Script de simulación de carga
├── destroy.sh                         # Script de destrucción segura ⚠️
└── .github/workflows/
    └── deploy.yml                     # Pipeline CI/CD (build → push → deploy)
```

---

## Requisitos previos

- AWS CLI configurado con credenciales de AWS Academy
- Terraform >= 1.0
- kubectl
- Docker Desktop

---

## Paso 1 — Crear la infraestructura con Terraform

```bash
cd infra
terraform init
terraform apply
```

Esto crea: VPC, subnets, Security Groups, EKS cluster, node group y 3 repositorios ECR.
Anota los outputs (URLs de ECR y nombre del clúster). **Tarda 10-15 minutos.**

---

## Paso 2 — Configurar kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name despacho-cluster
kubectl get nodes   # deben aparecer 2 nodos en estado Ready
```

---

## Paso 3 — Instalar EBS CSI Driver (para volúmenes)

```bash
aws eks associate-iam-oidc-provider --cluster-name despacho-cluster --region us-east-1 --approve
aws eks create-addon --cluster-name despacho-cluster --addon-name aws-ebs-csi-driver --service-account-role-arn arn:aws:iam::TU_ACCOUNT_ID:role/LabRole --resolve-conflicts OVERWRITE
```

---

## Paso 4 — Configurar Secrets en GitHub

En tu repositorio GitHub → Settings → Secrets → Actions:

| Secret | Descripción |
|---|---|
| `AWS_ACCESS_KEY_ID` | De tu lab AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | De tu lab AWS Academy |
| `AWS_SESSION_TOKEN` | De tu lab AWS Academy (se renueva cada sesión) |

---

## Paso 5 — Activar el pipeline CI/CD

```bash
git add .
git commit -m "feat: deploy a EKS"
git push origin deploy
```

El pipeline construye las 3 imágenes, las sube a ECR y despliega en EKS automáticamente.

---

## Paso 6 — Verificar el despliegue

```bash
kubectl get pods          # todos deben estar en 1/1 Running
kubectl get services      # buscar EXTERNAL-IP del frontend
kubectl get hpa           # ver estado del autoscaling
kubectl logs deployment/backend-despachos --tail=30
kubectl logs deployment/backend-ventas --tail=30
```

---

## Paso 7 — Simular carga (demostrar HPA)

```bash
bash k8s/load-test.sh http://TU_LOADBALANCER_URL
```

---

## ⚠️ DESTRUIR LA INFRAESTRUCTURA (IMPORTANTE)

**NUNCA ejecutes `terraform destroy` directamente.** Primero hay que eliminar los recursos de Kubernetes para que el LoadBalancer libere las IPs públicas, si no Terraform fallará al intentar eliminar las subnets y el Internet Gateway.

**Usa siempre el script de destrucción segura:**

```bash
bash destroy.sh
```

El script hace todo en el orden correcto:
1. Elimina los pods y servicios de Kubernetes (libera el LoadBalancer)
2. Espera 60 segundos para que AWS elimine el LoadBalancer
3. Ejecuta terraform destroy

---

## Autoscaling (HPA)

| Servicio | Min pods | Max pods | Umbral CPU |
|---|---|---|---|
| backend-despachos | 2 | 5 | 50% |
| backend-ventas | 2 | 5 | 50% |
| frontend | 1 | 3 | 50% |
