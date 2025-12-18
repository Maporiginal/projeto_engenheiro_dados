#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# --- helpers: roda terraform dentro do container ---
tf() {
  docker exec -i terraform sh -lc "cd /iac && $*"
}

tf_has_state() {
  local addr="$1"
  tf "terraform state list" | grep -qx "$addr"
}

tf_import_if_missing() {
  local addr="$1"
  local id="$2"

  if tf_has_state "$addr"; then
    echo "[TF] OK state já tem: $addr"
    return 0
  fi

  echo "[TF] import: $addr <= $id"
  set +e
  tf "terraform import -input=false $addr '$id'"
  rc=$?
  set -e

  if [ $rc -ne 0 ]; then
    echo "[TF] import falhou para $addr (talvez não exista ainda). Continuando..."
  fi
}

# 1) Init + validações
tf "terraform init"
tf "terraform fmt -recursive"
tf "terraform validate"

# 2) IMPORT (se já existir na AWS)
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

GLUE_DB_NAME="metadata-database-raw-curated"
RAW_CRAWLER="lab-raw-crawler"
CURATED_CRAWLER="lab-curated-crawler"
LAMBDA_FN="lab-clientes-api"
GLUE_ROLE="lab-glue-role"
LAMBDA_ROLE="lab-lambda-clientes-role"

tf_import_if_missing "aws_iam_role.glue_role" "$GLUE_ROLE"
tf_import_if_missing "aws_iam_role.lambda_clientes_role" "$LAMBDA_ROLE"
tf_import_if_missing "aws_glue_catalog_database.metadata" "${ACCOUNT_ID}:${GLUE_DB_NAME}"
tf_import_if_missing "aws_glue_crawler.raw_crawler" "$RAW_CRAWLER"
tf_import_if_missing "aws_glue_crawler.curated_crawler" "$CURATED_CRAWLER"
tf_import_if_missing "aws_lambda_function.clientes_api" "$LAMBDA_FN"

# (opcional) Se você também tem Glue Job no tf, e ele já existe:
# tf_import_if_missing "aws_glue_job.unified_job" "lab-unified-job"

# 3) Agora sim: plan/apply
tf "terraform plan"
tf "terraform apply -auto-approve"

# 4) Seu passo 2 (Glue) continua igual (AWS CLI no host)
RAW="$RAW_CRAWLER"
CURATED="$CURATED_CRAWLER"
JOB="lab-unified-job"
BUCKET="maporiginal-data-lake-dev-us-east-1-20251215"

wait_crawler() {
  local crawler_name="$1"
  echo "Waiting crawler: $crawler_name ..."
  while true; do
    state=$(aws glue get-crawler --name "$crawler_name" --query 'Crawler.State' --output text)
    [ "$state" = "READY" ] && break
    sleep 10
  done
  last=$(aws glue get-crawler --name "$crawler_name" --query 'Crawler.LastCrawl.Status' --output text)
  echo "Crawler $crawler_name LastCrawl.Status: $last"
  if [ "$last" != "SUCCEEDED" ]; then
    echo "ERROR: crawler $crawler_name terminou sem SUCCEEDED (status=$last)"
    exit 1
  fi
}

# ... resto do seu script (start-crawler, start-job-run etc.)

