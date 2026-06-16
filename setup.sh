#!/bin/bash
# =============================================================================
# setup.sh — Levanta el proyecto completo automaticamente
# Uso: bash setup.sh
# =============================================================================

set -e

CLUSTER_NAME="despacho-cluster"
REGION="us-east-1"
REPO="https://github.com/NataliaVarela17/evaluacion3-devops.git"
CARPETA="evaluacion3-devops"

echo ""
echo "=================================================="
echo "   Levantamiento automatico del proyecto EP3"
echo "=================================================="
echo ""

# ─── Paso 1: Clonar el repositorio si no existe ───────────────────────────────
if [ ! -d "$CARPETA" ]; then
  echo "▶ Paso 1: Clonando el repositorio..."
  git clone $REPO
  cd $CARPETA
else
  echo "▶ Paso 1: Repositorio ya existe, actualizando..."
  cd $CARPETA
  git pull origin master
  git pull origin deploy
fi
echo "✅ Repositorio listo"
echo ""

# ─── Paso 2: Pedir credenciales de AWS ───────────────────────────────────────
echo "▶ Paso 2: Configurar credenciales de AWS Academy"
echo "   (Copiala desde AWS Academy -> AWS Details -> Show)"
echo ""
read -p "   AWS Access Key ID: " AWS_KEY
read -p "   AWS Secret Access Key: " AWS_SECRET
read -p "   AWS Session Token (texto largo): " AWS_TOKEN
echo ""

aws configure set aws_access_key_id "$AWS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET"
aws configure set default.region "$REGION"
aws configure set aws_session_token "$AWS_TOKEN"

# Verificar que las credenciales funcionan
aws sts get-caller-identity > /dev/null 2>&1
echo "✅ Credenciales de AWS configuradas correctamente"
echo ""

# ─── Paso 3: Crear infraestructura con Terraform ─────────────────────────────
echo "▶ Paso 3: Creando infraestructura en AWS con Terraform..."
echo "   (Esto tarda entre 10 y 15 minutos)"
echo ""
cd infra
terraform init -input=false
terraform apply -auto-approve
cd ..
echo "✅ Infraestructura creada"
echo ""

# ─── Paso 4: Conectar kubectl ─────────────────────────────────────────────────
echo "▶ Paso 4: Conectando kubectl al cluster EKS..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
kubectl get nodes
echo "✅ kubectl conectado al cluster"
echo ""

# ─── Paso 5: Pedir secrets de GitHub y disparar pipeline ─────────────────────
echo "▶ Paso 5: Actualizando secrets en GitHub y disparando pipeline"
echo ""
echo "   Necesitas actualizar manualmente los 3 secrets en GitHub:"
echo "   1. Ve a: https://github.com/NataliaVarela17/evaluacion3-devops"
echo "   2. Settings -> Secrets and variables -> Actions"
echo "   3. Actualiza:"
echo "      - AWS_ACCESS_KEY_ID:     $AWS_KEY"
echo "      - AWS_SECRET_ACCESS_KEY: $AWS_SECRET"
echo "      - AWS_SESSION_TOKEN:     (el token largo que ingresaste)"
echo ""
read -p "   Presiona ENTER cuando hayas actualizado los secrets en GitHub..."

# Disparar el pipeline
echo ""
echo "▶ Disparando el pipeline CI/CD..."
git commit --allow-empty -m "trigger: levantar proyecto automaticamente"
git push origin deploy
echo "✅ Pipeline disparado"
echo ""

# ─── Paso 6: Esperar que el pipeline termine ─────────────────────────────────
echo "▶ Paso 6: Esperando que el pipeline suba las imagenes a ECR..."
echo "   (Esto tarda entre 5 y 10 minutos)"
echo "   Puedes ver el progreso en: https://github.com/NataliaVarela17/evaluacion3-devops/actions"
echo ""
echo "   Esperando 8 minutos..."
sleep 480
echo ""

# ─── Paso 7: Aplicar manifests de Kubernetes ─────────────────────────────────
echo "▶ Paso 7: Desplegando servicios en Kubernetes..."
kubectl apply -f k8s/mysql.yml
sleep 10
kubectl apply -f k8s/backend-despachos.yml
kubectl apply -f k8s/backend-ventas.yml
kubectl apply -f k8s/frontend.yml
kubectl apply -f k8s/hpa.yml
echo "✅ Servicios desplegados"
echo ""

# ─── Paso 8: Esperar que los pods esten listos ───────────────────────────────
echo "▶ Paso 8: Esperando que los pods esten listos..."
echo "   (Puede tardar 3-5 minutos)"
sleep 60

MAX_INTENTOS=10
INTENTO=0
while [ $INTENTO -lt $MAX_INTENTOS ]; do
  PENDING=$(kubectl get pods --no-headers | grep -v "Running" | wc -l)
  if [ "$PENDING" -eq "0" ]; then
    break
  fi
  echo "   Pods aun iniciando... ($INTENTO/$MAX_INTENTOS)"
  sleep 30
  INTENTO=$((INTENTO + 1))
done

echo ""
echo "▶ Estado de los pods:"
kubectl get pods
echo ""

# ─── Paso 9: Obtener URL publica ─────────────────────────────────────────────
echo "▶ Paso 9: Obteniendo URL publica del frontend..."
sleep 30
URL=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

echo ""
echo "=================================================="
echo "  Proyecto levantado exitosamente!"
echo "=================================================="
echo ""
echo "  Frontend: http://$URL"
echo "  Swagger Despachos: (acceso interno via kubectl)"
echo "  Swagger Ventas:    (acceso interno via kubectl)"
echo ""
echo "  Comandos utiles:"
echo "  kubectl get pods        -> ver estado de los pods"
echo "  kubectl get services    -> ver servicios"
echo "  kubectl get hpa         -> ver autoscaling"
echo "  kubectl logs deployment/backend-despachos -> ver logs"
echo ""
echo "  Para DESTRUIR todo: bash destroy.sh"
echo "=================================================="
