# =====================================================
# Buckets S3
# =====================================================

# Sufixo aleatório para garantir unicidade global
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket de deploy: guarda o JAR e os scripts SQL
# para que a EC2 baixe via aws-cli no boot.
resource "aws_s3_bucket" "Bucket_CarePlus_Deploy" {
  bucket        = "careplus-deploy-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = { Name = "Bucket_CarePlus_Deploy" }
}

# =====================================================
# Upload dos artefatos para o bucket de deploy
# =====================================================
resource "aws_s3_object" "careplus_jar" {
  bucket = aws_s3_bucket.Bucket_CarePlus_Deploy.id
  key    = "careplus.jar"
  source = "${path.module}/careplus-0.0.1-SNAPSHOT.jar"
  etag   = filemd5("${path.module}/careplus-0.0.1-SNAPSHOT.jar")
}

resource "aws_s3_object" "careplus_consolidated_sql" {
  bucket = aws_s3_bucket.Bucket_CarePlus_Deploy.id
  key    = "careplus-consolidated.sql"
  source = "${path.module}/scripts/careplus-consolidated.sql"
  etag   = filemd5("${path.module}/scripts/careplus-consolidated.sql")
}

resource "aws_s3_object" "mensageria_jar" {
  bucket = aws_s3_bucket.Bucket_CarePlus_Deploy.id
  key    = "mensageria.jar"
  source = "${path.module}/mensageria-0.0.1-SNAPSHOT.jar"
  etag   = filemd5("${path.module}/mensageria-0.0.1-SNAPSHOT.jar")
}

# =====================================================
# Upload do build do frontend (dist/) para o S3
# =====================================================
locals {
  frontend_mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain"
    ".woff" = "font/woff"
    ".woff2" = "font/woff2"
  }

  frontend_files = fileset("${path.module}/dist", "**")
}

resource "aws_s3_object" "frontend_files" {
  for_each = local.frontend_files

  bucket       = aws_s3_bucket.Bucket_CarePlus_Deploy.id
  key          = "frontend/${each.value}"
  source       = "${path.module}/dist/${each.value}"
  etag         = filemd5("${path.module}/dist/${each.value}")
  content_type = lookup(local.frontend_mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
}
