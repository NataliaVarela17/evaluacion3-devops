#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# destroy.sh — Destruye toda la infraestructura de forma segura
#
# PROBLEMA que resuelve:
# Si haces "terraform destroy" directamente, falla porque el LoadBalancer
# de Kubernetes crea IPs públicas en AWS que Terraform no puede eliminar
# mientras estén en uso. Hay que eliminar los recursos de Kubernetes PRIMERO.
#
# Uso: bash destroy.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

echo "=================================================="
echo " Destrucción segura del proyecto"
echo "=================================================="
echo ""

# Paso 1: Verificar que kubectl está conectado al clúster
echo "▶ Paso 1: Verificando conexión al clúster EKS..."
if kubectl get nodes > /dev/null 2>&1; then
  echo "✅ kubectl conectado al clúster"

  # Paso 2: Eliminar recursos de Kubernetes (libera el LoadBalancer y las IPs)
  echo ""
  echo "▶ Paso 2: Eliminando recursos de Kubernetes..."
  echo "   (Esto libera el LoadBalancer y las IPs públicas de AWS)"
  kubectl delete -f k8s/ --ignore-not-found=true
  echo "✅ Recursos de Kubernetes eliminados"

  # Paso 3: Esperar a que el LoadBalancer se elimine completamente en AWS
  echo ""
  echo "▶ Paso 3: Esperando 60 segundos para que AWS elimine el LoadBalancer..."
  sleep 60
  echo "✅ Espera completada"
else
  echo "⚠️  kubectl no está conectado. Si el clúster ya no existe, continuando..."
fi

# Paso 4: Destruir la infraestructura con Terraform
echo ""
echo "▶ Paso 4: Ejecutando terraform destroy..."
cd infra
terraform destroy -auto-approve
echo ""
echo "✅ Infraestructura eliminada correctamente"
echo "=================================================="
