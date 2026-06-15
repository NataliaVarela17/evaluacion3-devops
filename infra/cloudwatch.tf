# ─── CloudWatch Log Groups ────────────────────────────────────────────────────
# Cada servicio tiene su propio grupo de logs en CloudWatch
# Los logs se retienen 7 días para no generar costos excesivos

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/eks/despacho-cluster/frontend"
  retention_in_days = 7

  tags = {
    Name = "frontend-logs"
  }
}

resource "aws_cloudwatch_log_group" "backend_despachos" {
  name              = "/eks/despacho-cluster/backend-despachos"
  retention_in_days = 7

  tags = {
    Name = "backend-despachos-logs"
  }
}

resource "aws_cloudwatch_log_group" "backend_ventas" {
  name              = "/eks/despacho-cluster/backend-ventas"
  retention_in_days = 7

  tags = {
    Name = "backend-ventas-logs"
  }
}

resource "aws_cloudwatch_log_group" "mysql" {
  name              = "/eks/despacho-cluster/mysql"
  retention_in_days = 7

  tags = {
    Name = "mysql-logs"
  }
}
