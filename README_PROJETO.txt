# README — Laboratório Eng. de Dados (SUSE Leap + Docker + AWS Glue/Athena + API + Power BI)

## Visão geral
Este repositório sobe um laboratório de engenharia de dados com:

- Containers locais (Postgres / MySQL / Mongo + ingestor)
- Ingestão para **S3** nas camadas **raw** e **curated**
- **AWS Glue** (crawlers + job) para catalogar e gerar tabela final
- **Athena** para consulta
- **API Gateway + Lambda** para endpoint `/clientes?nome=...`
- Conexão no **Power BI** via **ODBC Simba Athena**

> OBS: todas as credenciais ficam no arquivo .env


## Ambiente utilizado
- SUSE Leap **16**
- Docker Engine + Docker Compose v2
- Git
- AWS CLI v2
- (Windows) Power BI Desktop + Simba Athena ODBC Driver


## 1) Preparação do SUSE Leap (host)

### 1.1 Atualização e utilitários

sudo zypper refresh
sudo zypper update -y
sudo zypper install -y unzip


### 1.2 Firewall (SSH + portas dos bancos)

sudo firewall-cmd --zone=public --permanent --add-service=ssh
sudo firewall-cmd --zone=public --permanent --add-port=5432/tcp
sudo firewall-cmd --zone=public --permanent --add-port=15432/tcp
sudo firewall-cmd --zone=public --permanent --add-port=27017/tcp
sudo firewall-cmd --zone=public --permanent --add-port=3306/tcp
sudo firewall-cmd --zone=public --permanent --add-port=13306/tcp
sudo firewall-cmd --reload


## 2) Docker + Docker Compose v2

### 2.1 Instalar e habilitar Docker

sudo zypper install -y docker
sudo systemctl enable --now docker
sudo systemctl status docker --no-pager


### 2.2 Permitir seu usuário usar Docker (sem sudo)

sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker <SEU_USUARIO>
newgrp docker


### 2.3 Instalar Docker Compose v2 (plugin)

sudo mkdir -p /usr/local/lib/docker/cli-plugins

sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version


### 2.4 Teste rápido

docker run --rm hello-world


## 3) Git + SSH (clone via GitHub)
sudo zypper install -y git 
git --version

git clone https://github.com/Maporiginal/projeto_engenheiro_dados.git


## 4) AWS — configuração mínima (uma vez)



### 4.1 Criar usuário IAM (exemplo)
primeiro eu criei a potilica de nome com acesso de admin: 
lab-ingestor-s3-raw-curated

{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid": "AdministratorAccess", "Effect": "Allow", "Action": "*", "Resource": "*" }
  ]
}

Criar um usuário IAM (ex.: `lab-ingestor`) e gerar credenciais **para CLI**.
coloquei a politica que acabamos de criar 

criar a chave de acesso que guardar o aws access e secret no formato command in interface (CLI)


## 5) AWS CLI v2 + credenciais no SUSE

### 5.1 Instalar AWS CLI v2 no home

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version


### 5.2 Configurar profile

aws configure --profile lab-ingestor
# AWS Access Key ID: <AWS_ACCESS_KEY_ID>
# AWS Secret Access Key: <AWS_SECRET_ACCESS_KEY>
# Default region name: us-east-1
# Default output format: json


### 5.3 Testar credenciais

aws --profile lab-ingestor sts get-caller-identity
aws --profile lab-ingestor s3 ls s3://<NOME_DO_BUCKET>/

## 6) Configurar .env

No diretório:
`/home/matheus/projeto_engenheiro_dados/data_bases/.env`

Como .env foi usado, configure com suas credenciais:

# Postgres
PG_SUPERUSER=postgres
PG_SUPERPASS=postgres

# MySQL
MYSQL_ROOT_PASSWORD=mysql
MYSQL_APP_USER=mysql
MYSQL_APP_PASS=mysql

# Mongo
MONGO_ROOT_USER=mongo
MONGO_ROOT_PASS=mongo

# AWS
AWS_REGION=us-east-1
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID_AQUI>
AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY_AQUI>

S3_BUCKET=<NOME_DO_BUCKET>

# Glue/Lambda padrões
GLUE_DB_NAME=metadata-database-raw-curated
GLUE_CRAWLER_RAW=lab-raw-crawler
GLUE_CRAWLER_CURATED=lab-curated-crawler
GLUE_JOB_NAME=lab-unified-job

IAM_GLUE_ROLE_NAME=lab-glue-role
IAM_LAMBDA_ROLE_NAME=lab-lambda-clientes-role

LAMBDA_FN_NAME=lab-clientes-api
LAMBDA_PERMISSION_STATEMENT_ID=AllowInvokeFromAPIGateway

TERRAFORM_CONTAINER=terraform
TF_IAC_DIR=/iac


## 7) Subir os containers do laboratório
Na pasta `data_bases/`:


docker compose build
docker compose up -d
docker ps


## 8) Rodar pipeline (Terraform + Crawlers + Glue Job)
Na pasta data_bases/iac/:

./run_pipeline.sh



## 9) Validar Athena
No console do Athena (ou via query), confirme que a tabela final existe e consulta ok:

SELECT * FROM clientes_unificados LIMIT 10;


## 10) Testar API (Postman / curl)

### Endpoint
`GET /clientes?nome=<PARTE_DO_NOME>`

Exemplo:

https://<API_ID>.execute-api.us-east-1.amazonaws.com/clientes?nome=Carla


## 11) Power BI via ODBC (Simba Athena)

### 11.1 Instalar driver Simba
Baixar/instalar o driver ODBC do Athena (Simba).

### 11.2 Configurar DSN no Windows
- `Win + R` → `odbcad32.exe`
- **System DSN**
- Driver: **Simba Athena**
- Preencher:
  - Region: `us-east-1`
  - Schema/Database: `metadata-database-raw-curated` (ou o seu)
  - S3 Output Location: `s3://<NOME_DO_BUCKET>/athena-results/`
  - Authentication:
    - Access Key: `<AWS_ACCESS_KEY_ID>`
    - Secret Key: `<AWS_SECRET_ACCESS_KEY>`

### 11.3 Power BI
- Transformar dados → Nova fonte → Athena/ODBC
- Escolher DSN configurado
- Importar tabelas desejadas

## Status do projeto
- ✅ S3 raw/curated funcionando
- ✅ Glue Crawlers / Glue Job funcionando
- ✅ Athena tabela consultável
- ⚠️ API (API Gateway + Lambda) Está apresentando alguns erros.
