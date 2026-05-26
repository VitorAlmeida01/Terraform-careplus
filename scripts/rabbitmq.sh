#!/bin/bash
# =====================================================
# Bootstrap RabbitMQ + Mensageria EC2
# - Instala Docker e Java 21
# - Sobe RabbitMQ 3 com painel de gerenciamento
# - Baixa e executa o serviço de mensageria do S3
# =====================================================
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "[$(date)] Iniciando bootstrap RabbitMQ + Mensageria"

# ===== SETUP BÁSICO =====
apt-get update -y
apt-get install -y docker.io openjdk-21-jre-headless unzip curl
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Espera Docker subir
until docker info >/dev/null 2>&1; do
  echo "[$(date)] Aguardando Docker..."
  sleep 2
done

# ===== INSTALAR AWS CLI v2 =====
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q -o awscliv2.zip
./aws/install --update >/dev/null 2>&1
rm -rf awscliv2.zip aws

# ===== INICIAR RABBITMQ =====
docker run -d \
  --name rabbitmq \
  --restart always \
  -e RABBITMQ_DEFAULT_USER=guest \
  -e RABBITMQ_DEFAULT_PASS=guest \
  -p 5672:5672 \
  -p 15672:15672 \
  rabbitmq:3-management

echo "[$(date)] RabbitMQ iniciado"

# ===== AGUARDAR RABBITMQ ESTAR PRONTO =====
echo "[$(date)] Aguardando RabbitMQ estar pronto..."
for i in {1..120}; do
  if docker exec rabbitmq rabbitmq-diagnostics ping >/dev/null 2>&1; then
    echo "[$(date)] RabbitMQ pronto (ping OK)"
    sleep 5
    break
  fi
  echo "[$(date)] Tentativa $i/120..."
  sleep 3
done

echo "[$(date)] Fazendo health check da porta 5672..."
for i in {1..30}; do
  if timeout 2 bash -c "echo > /dev/tcp/localhost/5672" 2>/dev/null; then
    echo "[$(date)] ✓ RabbitMQ AMQP (5672) respondendo"
    break
  fi
  echo "[$(date)] Aguardando porta 5672... tentativa $i/30"
  sleep 2
done

sleep 5
echo "[$(date)] ✓ RabbitMQ 100% pronto"

# ===== CONFIGURAR DIRETÓRIO PARA MENSAGERIA =====
mkdir -p /opt/mensageria
cd /opt/mensageria

# ===== BAIXAR JAR DO S3 =====
echo "[$(date)] Baixando mensageria.jar do S3..."
if ! aws s3 cp s3://${bucket_name}/mensageria.jar . --no-progress; then
  echo "[$(date)] ✗ ERRO: Falha ao baixar mensageria.jar do S3"
  echo "[$(date)] Bucket: ${bucket_name}"
  exit 1
fi

if [ ! -f mensageria.jar ]; then
  echo "[$(date)] ✗ ERRO: mensageria.jar não encontrado após download"
  ls -la /opt/mensageria/
  exit 1
fi

echo "[$(date)] ✓ mensageria.jar baixado com sucesso"
ls -lh mensageria.jar

# ===== EXECUTAR MENSAGERIA =====
echo "[$(date)] Iniciando Mensageria..."
nohup java -jar mensageria.jar \
  --spring.profiles.active=twilio \
  --server.port=8081 \
  --spring.rabbitmq.host=localhost \
  --spring.rabbitmq.port=5672 \
  --spring.rabbitmq.username=guest \
  --spring.rabbitmq.password=guest \
  --spring.rabbitmq.connection-timeout=30000 \
  --spring.rabbitmq.requested-heartbeat=60 \
  --spring.rabbitmq.channel-close-timeout=30000 \
  --spring.rabbitmq.network-recovery-interval=5000 \
  --spring.rabbitmq.automatic-recovery-enabled=true \
  > /var/log/mensageria.log 2>&1 &

sleep 5

if ps aux | grep -q "[j]ava.*mensageria.jar"; then
  echo "[$(date)] ✓ Mensageria iniciado com sucesso"
  echo "[$(date)] Aguardando Mensageria estar 100% pronta..."
  sleep 10
else
  echo "[$(date)] ✗ ERRO: Mensageria falhou ao iniciar"
  echo "[$(date)] Últimas linhas do log:"
  tail -20 /var/log/mensageria.log
  exit 1
fi

echo "========================================="
echo "✓ RabbitMQ + Mensageria - Bootstrap Completo!"
echo "========================================="
echo "RabbitMQ Painel: http://<IP>:15672 (guest/guest)"
echo "RabbitMQ AMQP:   <IP>:5672"
echo "Mensageria:      http://<IP>:8081"
echo "Logs RabbitMQ:   docker logs -f rabbitmq"
echo "Logs Mensageria: tail -f /var/log/mensageria.log"
echo "========================================="
