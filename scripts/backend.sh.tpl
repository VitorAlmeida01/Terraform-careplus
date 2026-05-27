#!/bin/bash
# =====================================================
# Bootstrap Backend + Banco de Dados
# - Instala Docker e AWS CLI
# - Baixa JAR e scripts SQL do S3
# - Sobe MySQL (carregando bd_v2.sql + inserts.sql na inicialização)
# - Sobe CarePlus (Spring Boot) apontando para
#   MySQL local e RabbitMQ remoto.
# =====================================================
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "[$(date)] Iniciando bootstrap Backend+DB"

# ----- Variáveis injetadas pelo Terraform -----
RABBITMQ_HOST="${rabbitmq_private_ip}"
BUCKET_NAME="${bucket_name}"
# ----------------------------------------------

DEPLOY_DIR=/opt/careplus
MYSQL_INIT=$DEPLOY_DIR/mysql-init

apt-get update -y
apt-get install -y docker.io netcat-openbsd unzip curl
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# AWS CLI v2 (oficial — Ubuntu 24.04 não tem mais awscli no apt)
echo "[$(date)] Instalando AWS CLI v2..."
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q -o awscliv2.zip
./aws/install --update
cd -
aws --version

until docker info >/dev/null 2>&1; do
  echo "Aguardando Docker..."
  sleep 2
done

mkdir -p $DEPLOY_DIR $MYSQL_INIT
cd $DEPLOY_DIR

echo "[$(date)] Baixando artefatos do S3 ($BUCKET_NAME)..."
if ! aws s3 cp s3://$BUCKET_NAME/careplus.jar $DEPLOY_DIR/careplus.jar; then
    echo "[$(date)] ✗ ERRO ao baixar careplus.jar"
    exit 1
fi

if ! aws s3 cp s3://$BUCKET_NAME/careplus-consolidated.sql $MYSQL_INIT/01_careplus-consolidated.sql; then
    echo "[$(date)] ✗ ERRO ao baixar careplus-consolidated.sql"
    exit 1
fi

echo "[$(date)] ✓ Artefatos baixados com sucesso:"
ls -lh $DEPLOY_DIR/careplus.jar $MYSQL_INIT/01_careplus-consolidated.sql

if [ ! -f "$DEPLOY_DIR/careplus.jar" ]; then
    echo "[$(date)] ✗ ERRO: careplus.jar não encontrado!"
    exit 1
fi

# Rede docker compartilhada entre app e mysql
docker network create careplus-net || true

# ----- MySQL -----
echo "[$(date)] Subindo MySQL..."
docker run -d \
  --name careplus-mysql \
  --network careplus-net \
  --restart always \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=careplus_novo \
  -p 3306:3306 \
  -v $MYSQL_INIT:/docker-entrypoint-initdb.d \
  mysql:8 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci

# Espera MySQL responder a ping
echo "[$(date)] Aguardando MySQL..."
for i in $(seq 1 60); do
  if docker exec careplus-mysql mysqladmin ping -h localhost -uroot -proot --silent 2>/dev/null; then
    echo "MySQL OK"
    break
  fi
  echo "  tentativa $i/60..."
  sleep 5
done

# Espera RabbitMQ ficar pronto (porta 5672 aceitando conexão)
echo "[$(date)] Aguardando RabbitMQ em $RABBITMQ_HOST:5672..."
for i in $(seq 1 120); do
  if nc -z -w 3 "$RABBITMQ_HOST" 5672; then
    echo "[$(date)] ✓ RabbitMQ OK - porta 5672 respondendo"
    sleep 3
    break
  fi
  echo "[$(date)]   tentativa $i/120..."
  sleep 3
done

echo "[$(date)] Fazendo verificação adicional de RabbitMQ..."
sleep 5

# ----- Backend (CarePlus) -----
# Pega o IP do container MySQL para usar com --network host
# (com host network o Docker DNS não resolve nomes de containers)
MYSQL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' careplus-mysql)
echo "[$(date)] IP do MySQL: $MYSQL_IP"

echo "[$(date)] Subindo Backend CarePlus..."
docker run -d \
  --name careplus-app \
  --network host \
  --restart always \
  -e "SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_IP:3306/careplus_novo?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&serverTimezone=UTC" \
  -e 'SPRING_DATASOURCE_USERNAME=careplus_user' \
  -e 'SPRING_DATASOURCE_PASSWORD=SenhaForte123!' \
  -e "SPRING_RABBITMQ_HOST=$RABBITMQ_HOST" \
  -e 'SPRING_RABBITMQ_PORT=5672' \
  -e 'SPRING_RABBITMQ_USERNAME=guest' \
  -e 'SPRING_RABBITMQ_PASSWORD=guest' \
  -e 'SPRING_RABBITMQ_CONNECTION_TIMEOUT=30000' \
  -e 'SPRING_RABBITMQ_REQUESTED_HEARTBEAT=60' \
  -e 'SPRING_RABBITMQ_CHANNEL_CLOSE_TIMEOUT=30000' \
  -e 'SPRING_RABBITMQ_NETWORK_RECOVERY_INTERVAL=5000' \
  -e 'SPRING_RABBITMQ_AUTOMATIC_RECOVERY_ENABLED=true' \
  -e 'AWS_DEFAULT_REGION=us-east-1' \
  -e 'AWS_S3_BUCKET_NAME=bucket-prontuarios-4' \
  -e 'AWS_S3_BUCKET_RENOVAR_AGENDA_NAME=renovar-agenda-careplus' \
  -e 'JAVA_TOOL_OPTIONS=-Xms256m -Xmx768m' \
  -v $DEPLOY_DIR/careplus.jar:/app/app.jar:ro \
  eclipse-temurin:21-jre-alpine \
  java -jar /app/app.jar

echo "[$(date)] Backend iniciando. Acompanhe com: docker logs -f careplus-app"
echo "  - Backend:    http://<EIP>:8080"
echo "  - MySQL:      <EIP>:3306 (careplus_user / SenhaForte123!)"
echo "  - RabbitMQ:   $RABBITMQ_HOST:5672 (interno via VPC)"
