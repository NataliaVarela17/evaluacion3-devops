#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Script de simulación de carga — demuestra el HPA en acción
# Uso: ./load-test.sh <URL_DEL_LOADBALANCER>
# Ejemplo: ./load-test.sh http://aab95700f76d74.us-east-1.elb.amazonaws.com
# ─────────────────────────────────────────────────────────────────────────────

URL=${1:-"http://localhost:3000"}
DURACION=120   # segundos que dura la prueba
CONCURRENCIA=50 # peticiones simultáneas

echo "=================================================="
echo " Simulación de carga — Proyecto Despacho"
echo "=================================================="
echo " URL:          $URL"
echo " Duración:     $DURACION segundos"
echo " Concurrencia: $CONCURRENCIA peticiones simultáneas"
echo "=================================================="
echo ""

# Verificar que la URL está disponible
echo "▶ Verificando que el frontend está disponible..."
if ! curl -s --max-time 10 "$URL" > /dev/null; then
  echo "❌ No se puede conectar a $URL"
  echo "   Asegúrate de que el LoadBalancer esté activo."
  exit 1
fi
echo "✅ Frontend disponible"
echo ""

# Mostrar estado inicial del HPA
echo "▶ Estado INICIAL del HPA:"
kubectl get hpa
echo ""

# Mostrar estado inicial de los pods
echo "▶ Pods ANTES de la prueba:"
kubectl get pods
echo ""

echo "▶ Iniciando simulación de carga por $DURACION segundos..."
echo "   (Abre otra terminal y ejecuta: kubectl get hpa -w)"
echo ""

# Ejecutar la carga usando curl en bucle
INICIO=$(date +%s)
CONTADOR=0

while true; do
  AHORA=$(date +%s)
  ELAPSED=$((AHORA - INICIO))

  if [ $ELAPSED -ge $DURACION ]; then
    break
  fi

  # Lanzar múltiples peticiones en paralelo
  for i in $(seq 1 $CONCURRENCIA); do
    curl -s --max-time 5 "$URL" > /dev/null &
    curl -s --max-time 5 "$URL/api/v1/despachos" > /dev/null &
    curl -s --max-time 5 "$URL/api/v1/ventas" > /dev/null &
  done

  CONTADOR=$((CONTADOR + CONCURRENCIA * 3))
  echo "   [$ELAPSED s] Peticiones enviadas: $CONTADOR"
  sleep 2
done

wait
echo ""
echo "▶ Prueba de carga finalizada."
echo ""

# Esperar que el HPA reaccione
echo "▶ Esperando 30 segundos para que el HPA escale..."
sleep 30

# Mostrar estado del HPA después de la carga
echo "▶ Estado del HPA DESPUÉS de la prueba:"
kubectl get hpa
echo ""

echo "▶ Pods DESPUÉS de la prueba (deberían haber más):"
kubectl get pods
echo ""

echo "▶ Logs recientes del backend-despachos:"
kubectl logs deployment/backend-despachos --tail=20
echo ""

echo "=================================================="
echo " Prueba completada. Revisa los valores de REPLICAS"
echo " en el HPA — deberían haber aumentado."
echo "=================================================="
