# Infraestrutura CarePlus — Arquitetura e CI/CD

## Diagrama de Arquitetura

```
                          INTERNET
                              │
                    ┌─────────▼─────────┐
                    │  Internet Gateway  │
                    │    (IGW_CarePlus)  │
                    └─────────┬─────────┘
                              │
              ┌───────────────▼────────────────┐
              │         VPC_CarePlus            │
              │          10.0.0.0/16            │
              │                                 │
              │  ┌──────────────────────────┐   │
              │  │  Route Table Pública      │   │
              │  │  0.0.0.0/0 → IGW         │   │
              │  └──────┬──────────┬────────┘   │
              │         │          │             │
   ┌──────────▼──────┐  │  ┌──────▼──────────┐  │
   │ Subnet Pública 1│  │  │ Subnet Pública 2 │  │
   │  10.0.0.0/24   │  │  │  10.0.1.0/24    │  │
   │  us-east-1a    │  │  │  us-east-1b     │  │
   │                │  │  │                 │  │
   │ ┌────────────┐ │  │  │ ┌─────────────┐ │  │
   │ │EC2_Frontend│ │  │  │ │EC2_RabbitMQ │ │  │
   │ │  t3.micro  │ │  │  │ │  t3.micro   │ │  │
   │ │            │ │  │  │ │             │ │  │
   │ │  Nginx:80  │ │  │  │ │ RabbitMQ:   │ │  │
   │ │  /var/www/ │ │  │  │ │  5672 AMQP  │ │  │
   │ │  careplus/ │ │  │  │ │  15672 UI   │ │  │
   │ │            │ │  │  │ │             │ │  │
   │ │ EIP:       │ │  │  │ │ Mensageria: │ │  │
   │ │ 18.213.x.x │ │  │  │ │  :8081      │ │  │
   │ └─────┬──────┘ │  │  │ │             │ │  │
   │       │        │  │  │ │ EIP:        │ │  │
   │ ┌─────▼──────┐ │  │  │ │ 184.72.x.x  │ │  │
   │ │NAT Gateway │ │  │  │ └──────┬──────┘ │  │
   │ │(EIP_NAT)   │ │  │  └────────┼────────┘  │
   │ └─────┬──────┘ │  │           │            │
   │       │        │  │           │            │
   │  ┌────▼──────────────────┐    │            │
   │  │  Application LB (ALB) │    │            │
   │  │  lb-careplus          │    │            │
   │  │  Porta 80 → TG :8080  │    │            │
   │  └────────────┬──────────┘    │            │
   └───────────────┼───────────────┼────────────┘
                   │               │
              ┌────▼───────────────▼──────────┐
              │   Route Table Privada          │
              │   0.0.0.0/0 → NAT Gateway      │
              │   S3 → VPC Gateway Endpoint    │
              └────────────────┬───────────────┘
                               │
              ┌────────────────▼───────────────┐
              │       Subnet Privada            │
              │        10.0.2.0/24             │
              │        us-east-1a              │
              │                                │
              │  ┌───────────────────────────┐ │
              │  │    EC2_Backend (t3.small) │ │
              │  │    IP privado: 10.0.2.x   │ │
              │  │    Sem IP público          │ │
              │  │                           │ │
              │  │  ┌─────────────────────┐  │ │
              │  │  │ careplus-app        │  │ │
              │  │  │ Spring Boot :8080   │  │ │
              │  │  │ --network host      │  │ │
              │  │  └─────────────────────┘  │ │
              │  │                           │ │
              │  │  ┌─────────────────────┐  │ │
              │  │  │ careplus-mysql      │  │ │
              │  │  │ MySQL 8 :3306       │  │ │
              │  │  │ --network careplus  │  │ │
              │  │  └─────────────────────┘  │ │
              │  └───────────────────────────┘ │
              └────────────────────────────────┘

                         ┌───────────────────────────┐
                         │   Amazon S3               │
                         │                           │
                         │  careplus-deploy-XXXX     │
                         │  ├── careplus.jar          │
                         │  ├── mensageria.jar        │
                         │  ├── careplus-consol...sql │
                         │  └── frontend/ (dist)      │
                         │                           │
                         │  bucket-prontuarios-4     │
                         │  ├── funcionarios/         │
                         │  ├── pacientes/            │
                         │  └── prontuarios/          │
                         └───────────────────────────┘
```

---

## Fluxo de Requisição (Usuário → Sistema)

```
Usuário (Browser)
      │  HTTP :80
      ▼
EC2_Frontend (Nginx)
      │  proxy_pass http://ALB:80
      ▼
ALB lb-careplus (porta 80)
      │  forward → Target Group :8080
      ▼
EC2_Backend (Spring Boot :8080)
      │                    │                    │
      ▼                    ▼                    ▼
 MySQL :3306         RabbitMQ :5672       S3 (fotos)
 (local Docker)      (10.0.1.x via VPC)  (via VPC Endpoint)
                          │
                          ▼
                    Mensageria (Java)
                          │
                          ▼
                   Gmail SMTP (emails)
```

---

## Componentes Detalhados

### EC2 Frontend (`EC2_Frontend_CarePlus`)
| Item | Valor |
|------|-------|
| Tipo | t3.micro |
| Subnet | Pública 1 — 10.0.0.0/24 (us-east-1a) |
| IP Público | EIP fixo (18.213.x.x) |
| SO | Ubuntu 22.04 |
| Serviço | Nginx — serve React em `/var/www/careplus/` |
| Portas abertas | 80 (HTTP), 22 (SSH), 5173, 8080 |
| Função extra | Jump host para acessar o backend privado via SSH |

### EC2 Backend (`EC2_Backend_CarePlus`)
| Item | Valor |
|------|-------|
| Tipo | t3.small |
| Subnet | **Privada** — 10.0.2.0/24 (us-east-1a) |
| IP Público | **Nenhum** |
| SO | Ubuntu 22.04 |
| Serviços | Docker: `careplus-app` (Spring Boot :8080) + `careplus-mysql` (MySQL :3306) |
| Portas abertas | 8080 e 22 — **somente de dentro da VPC** (10.0.0.0/16) |
| Saída internet | Via NAT Gateway (para baixar imagens Docker e pacotes no bootstrap) |
| Acesso S3 | Via VPC Gateway Endpoint (sem passar pela internet) |
| Credenciais AWS | IAM Instance Profile (`LabInstanceProfile`) — sem chaves hardcoded |

### EC2 RabbitMQ (`EC2_RabbitMQ_CarePlus`)
| Item | Valor |
|------|-------|
| Tipo | t3.micro |
| Subnet | Pública 2 — 10.0.1.0/24 (us-east-1b) |
| IP Público | EIP fixo (184.72.x.x) |
| Serviços | Docker: `rabbitmq` (AMQP :5672, UI :15672) + Mensageria Java (:8081) |
| Portas abertas | 5672, 15672, 8081, 22 — públicas |

### Load Balancer (`lb-careplus`)
| Item | Valor |
|------|-------|
| Tipo | Application Load Balancer (ALB) |
| Subnets | Pública 1 + Pública 2 (multi-AZ) |
| Listener | HTTP :80 → forward → Target Group |
| Target | EC2_Backend porta 8080 |
| Health check | GET `/swagger-ui.html` → 200-399 |

### S3
| Bucket | Gerenciamento | Conteúdo |
|--------|--------------|----------|
| `careplus-deploy-XXXX` | Terraform | JAR do backend, JAR da mensageria, SQL do banco, build do frontend |
| `bucket-prontuarios-4` | Manual | Fotos de funcionários, fotos de pacientes, prontuários |

---

## Rede e Segurança

```
Subnet Pública 1 (10.0.0.0/24)   →  RT Pública → IGW → Internet
Subnet Pública 2 (10.0.1.0/24)   →  RT Pública → IGW → Internet
Subnet Privada   (10.0.2.0/24)   →  RT Privada → NAT Gateway → Internet
                                                → VPC Endpoint → S3
```

- O backend nunca é acessado diretamente pela internet
- SSH no backend só é possível passando pelo frontend como jump host:
  ```bash
  ssh -A -J ubuntu@<EIP_FRONTEND> ubuntu@<IP_PRIVADO_BACKEND>
  ```
- Credenciais AWS são fornecidas pelo IAM Instance Profile (sem `AWS_ACCESS_KEY_ID` hardcoded)

---

## Bootstrap (Primeira Inicialização das EC2s)

### EC2 RabbitMQ (script: `rabbitmq.sh`)
```
1. Instala Docker + AWS CLI v2
2. Sobe container rabbitmq:3-management
3. Aguarda RabbitMQ responder (ping)
4. Baixa mensageria.jar do S3
5. Executa mensageria: java -jar mensageria.jar
```

### EC2 Backend (script: `backend.sh.tpl`)
```
1. Instala Docker + AWS CLI v2
2. Aguarda Docker subir
3. Baixa careplus.jar e careplus-consolidated.sql do S3
4. Sobe container careplus-mysql (MySQL 8)
   └── Inicializa banco com careplus-consolidated.sql
5. Aguarda MySQL responder (mysqladmin ping)
6. Aguarda RabbitMQ responder na porta 5672
7. Obtém IP interno do container MySQL via docker inspect
8. Sobe container careplus-app (Spring Boot)
   ├── --network host (para acessar IMDSv2 sem hop extra)
   ├── SPRING_DATASOURCE_URL → MySQL local
   ├── SPRING_RABBITMQ_HOST → IP privado do RabbitMQ
   └── AWS_S3_BUCKET_NAME=bucket-prontuarios-4
```

### EC2 Frontend (script: `frontend.sh`)
```
1. Instala Nginx + AWS CLI v2
2. Sincroniza build do frontend do S3 para /var/www/careplus/
3. Configura Nginx: / → arquivos estáticos, /api → proxy para ALB
4. Inicia Nginx
```

---

## CI/CD — Pipelines GitHub Actions

Os repositórios do frontend e do backend são **separados** no GitHub, cada um com seu próprio pipeline. Os arquivos `.yml` ficam em `terraform-deploy/github-actions/` como referência.

### Pipeline Frontend (`frontend-deploy.yml`)

**Trigger:** push na branch `main` do repositório do frontend

```
GitHub Actions Runner
│
├── 1. Checkout do repositório
├── 2. Configura Node.js 24
├── 3. npm install + npm run build
│      └── working-directory: ./careplus
│
├── 4. rsync dist/ → EC2 Frontend
│      └── destino: /home/ubuntu/dist/  (evita problema de permissão)
│         usando: easingthemes/ssh-deploy@main
│
└── 5. SSH na EC2 Frontend:
       ├── sudo rsync /home/ubuntu/dist/ → /var/www/careplus/
       ├── sudo chown -R www-data:www-data /var/www/careplus
       └── sudo nginx -t && sudo systemctl reload nginx
```

**Secrets necessários:**
| Secret | Valor |
|--------|-------|
| `EC2_SSH_KEY` | Conteúdo do arquivo `vockey.pem` |
| `FRONTEND_HOST` | IP público do frontend (EIP) |

---

### Pipeline Backend (`backend-deploy.yml`)

**Trigger:** push na branch `main` do repositório do backend

```
GitHub Actions Runner
│
├── 1. Checkout do repositório
├── 2. Configura JDK 21 (Temurin)
├── 3. Cache do Maven (~/.m2/repository)
├── 4. mvn clean test  (roda testes)
├── 5. mvn -B package -DskipTests=true  (gera o JAR)
├── 6. Renomeia para careplus.jar
│
├── 7. SCP careplus.jar → EC2 Frontend /home/ubuntu/
│      (frontend age como jump host — única EC2 acessível externamente)
│
└── 8. SSH na EC2 Frontend (jump host):
       ├── Cria chave PEM temporária a partir do secret
       ├── SSH → EC2 Backend: mkdir -p /opt/careplus + chown ubuntu
       ├── SCP careplus.jar → EC2 Backend /opt/careplus/careplus.jar
       ├── SSH → EC2 Backend: docker restart careplus-app
       ├── Aguarda 30s
       ├── Verifica se container está Running
       ├── Imprime últimas 30 linhas do log
       └── Remove chave PEM temporária
```

**Secrets necessários:**
| Secret | Valor |
|--------|-------|
| `EC2_SSH_KEY` | Conteúdo do arquivo `vockey.pem` |
| `FRONTEND_HOST` | IP público do frontend (EIP) |
| `BACKEND_PRIVATE_IP` | IP privado do backend (ex: 10.0.2.216) |

---

### Diagrama CI/CD

```
Repositório Frontend (GitHub)          Repositório Backend (GitHub)
push → main                            push → main
         │                                      │
         ▼                                      ▼
  GitHub Actions                        GitHub Actions
  (ubuntu-latest)                       (ubuntu-latest)
         │                                      │
  npm build                             mvn package
         │                                      │
  rsync dist/ ──────────────┐     SCP careplus.jar ──────────┐
                            │                                 │
                            ▼                                 ▼
                   EC2 Frontend (Jump Host)         EC2 Frontend (Jump Host)
                   /home/ubuntu/dist/               /home/ubuntu/careplus.jar
                            │                                 │
                   sudo rsync →                    SSH -J → EC2 Backend
                   /var/www/careplus/              /opt/careplus/careplus.jar
                            │                                 │
                   nginx reload                    docker restart careplus-app
```

---

## Observações Importantes

- **Backend privado:** o backend **não tem IP público**. O único caminho de acesso é via frontend como jump host (`-J`). Isso vale para SSH e para o pipeline CI/CD.

- **IMDSv2 e Docker:** o container `careplus-app` usa `--network host` para conseguir acessar o serviço de metadados da EC2 (`169.254.169.254`) sem hop adicional. Isso é necessário para o Spring Boot obter credenciais AWS via Instance Profile.

- **Bucket de prontuários:** o bucket `bucket-prontuarios-4` é criado **manualmente** (não pelo Terraform). O Terraform gerencia o `careplus-deploy-XXXX`. A variável `AWS_S3_BUCKET_NAME=bucket-prontuarios-4` é injetada no container pelo `backend.sh.tpl`.

- **Novo deploy do backend muda o IP privado:** sempre que o `EC2_Backend_CarePlus` é recriado (taint + apply), o IP privado muda. É necessário:
  1. Atualizar o secret `BACKEND_PRIVATE_IP` no GitHub
  2. Atualizar a configuração do Nginx no frontend para apontar ao novo IP

- **Mensageria:** o serviço de mensageria consome a fila `consultas.criadas.queue` do RabbitMQ e envia emails via Gmail SMTP quando consultas são criadas.
