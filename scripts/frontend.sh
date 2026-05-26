#!/bin/bash
# =====================================================
# Bootstrap Frontend – Nginx
# - Instala Nginx e AWS CLI
# - Baixa o build do frontend do S3 (pasta frontend/)
# - Configura proxy reverso → backend:8080
# =====================================================
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "[$(date)] Iniciando bootstrap Frontend (Nginx)"

# ----- Variáveis injetadas pelo Terraform -----
BACKEND_PRIVATE_IP="${backend_private_ip}"
BUCKET_NAME="${bucket_name}"
# ----------------------------------------------

apt-get update -y
apt-get install -y nginx unzip curl

# AWS CLI v2
echo "[$(date)] Instalando AWS CLI v2..."
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q -o awscliv2.zip
./aws/install --update >/dev/null 2>&1
rm -rf awscliv2.zip aws
cd -
echo "[$(date)] AWS CLI versão: $(aws --version)"

# Diretório raiz do site
mkdir -p /var/www/careplus

echo "[$(date)] Baixando build do frontend do S3..."
if aws s3 sync s3://$BUCKET_NAME/frontend/ /var/www/careplus/ --delete; then
    echo "[$(date)] ✓ Frontend baixado com sucesso do S3"
else
    echo "[$(date)] ✗ ERRO: Falha ao baixar frontend do S3"
    echo "[$(date)] Bucket: $BUCKET_NAME"
    echo "[$(date)] Verificando arquivos no S3..."
    aws s3 ls s3://$BUCKET_NAME/frontend/ || echo "Sem acesso ao S3!"
    exit 1
fi

# Verificar se há arquivos
if [ ! -f /var/www/careplus/index.html ]; then
    echo "[$(date)] ✗ ERRO: index.html não encontrado após sync!"
    ls -la /var/www/careplus/
    exit 1
fi

chown -R www-data:www-data /var/www/careplus
chmod -R 755 /var/www/careplus
echo "[$(date)] ✓ Permissões ajustadas"

# Configura Nginx
# Heredoc sem aspas: $BACKEND_PRIVATE_IP é expandido pelo shell;
# \$uri, \$host, etc. viram $uri, $host que o Nginx interpreta.
cat > /etc/nginx/sites-available/careplus << NGINXEOF
server {
    listen 80 default_server;
    server_name _;

    client_max_body_size 10m;

    root /var/www/careplus;
    index index.html;

    # SPA fallback — React / Vue Router
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy reverso para o backend Spring Boot
    # /api/* → http://backend:8080/*  (prefixo /api removido)
    location /api/ {
        proxy_pass         http://$BACKEND_PRIVATE_IP:8080/;
        proxy_http_version 1.1;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_read_timeout 60s;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/careplus /etc/nginx/sites-enabled/careplus
rm -f /etc/nginx/sites-enabled/default

echo "[$(date)] Testando configuração Nginx..."
if nginx -t; then
    echo "[$(date)] ✓ Nginx configuração OK"
else
    echo "[$(date)] ✗ Erro na configuração Nginx!"
    exit 1
fi

systemctl enable nginx
systemctl restart nginx

echo "[$(date)] ✓ Nginx iniciado e habilitado"
echo "[$(date)] ✓ Bootstrap Frontend completo!"
echo "========================================="
echo "Frontend Deploy Completo!"
echo "Arquivos: $(ls -1 /var/www/careplus/ | wc -l) arquivos"
echo "========================================="
