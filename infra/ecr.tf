# ─── ECR: Backend Despachos ───────────────────────────────────────────────────
resource "aws_ecr_repository" "backend_despachos" {
  name = "backend-despachos"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name = "backend-despachos"
  }
}

# ─── ECR: Backend Ventas ──────────────────────────────────────────────────────
resource "aws_ecr_repository" "backend_ventas" {
  name = "backend-ventas"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name = "backend-ventas"
  }
}

# ─── ECR: Frontend ────────────────────────────────────────────────────────────
resource "aws_ecr_repository" "frontend" {
  name = "frontend-despacho"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name = "frontend-despacho"
  }
}
