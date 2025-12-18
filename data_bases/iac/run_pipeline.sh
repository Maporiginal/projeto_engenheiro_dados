#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# Carrega .env (exporta vars)
set -a
source "$(dirname "$0")/../.env"
set +a

# Valida variáveis obrigatórias
: "${AWS_REGION:?Faltou AWS_REGION no .env}"
: "${AWS_ACCESS_KEY_ID:?Faltou AWS_ACCESS_KEY_ID no .env}"
: "${AWS_SECRET_ACCESS_KEY:?Faltou AWS_SECRET_ACCESS_KEY no .env}"

: "${S3_BUCKET:?Faltou S3_BUCKET no .env}"

: "${GLUE_DB_NAME:?Faltou GLUE_DB_NAME no .env}"
: "${GLUE_CRAWLER_RAW:?Faltou GLUE_CRAWLER_RAW no .env}"
: "${GLUE_CRAWLER_CURATED:?Faltou GLUE_CRAWLER_CURATED no .env}"
: "${GLUE_JOB_NAME:?Faltou GLUE_JOB_NAME no .env}"

: "${IAM_GLUE_ROLE_NAME:?Faltou IAM_GLUE_ROLE_NAME no .env}"
: "${IAM_LAMBDA_ROLE_NAME:?Faltou IAM_LAMBDA_ROLE_NAME no .env}"
: "${LAMBDA_FN_NAME:?Faltou LAMBDA_FN_NAME no .env}"
: "${LAMBDA_PERMISSION_STATEMENT_ID:?Faltou LAMBDA_PERMISSION_STATEMENT_ID no .env}"

TERRAFORM_CONTAINER="${TERRAFORM_CONTAINER:-terraform}"
TF_IAC_DIR="${TF_IAC_DIR:-/iac}"

docker exec -it ingestor python main.py

# --- helpers: roda terraform dentro do container ---
tf() {
  docker exec -i \
    -e AWS_REGION="$AWS_REGION" \
    -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-$AWS_REGION}" \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    "$TERRAFORM_CONTAINER" sh -lc "cd '$TF_IAC_DIR' && $*"
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

awsr() {
  aws --region "$AWS_REGION" "$@"
}

# 1) Init + validações
tf "terraform init"
tf "terraform fmt -recursive"
tf "terraform validate"

# 2) IMPORT (se já existir na AWS)
ACCOUNT_ID="$(awsr sts get-caller-identity --query Account --output text)"

LAMBDA_PERMISSION_ID="${LAMBDA_FN_NAME}/${LAMBDA_PERMISSION_STATEMENT_ID}"

tf_import_if_missing "aws_iam_role.glue_role" "$IAM_GLUE_ROLE_NAME"
tf_import_if_missing "aws_iam_role.lambda_clientes_role" "$IAM_LAMBDA_ROLE_NAME"
tf_import_if_missing "aws_glue_catalog_database.metadata" "${ACCOUNT_ID}:${GLUE_DB_NAME}"
tf_import_if_missing "aws_glue_crawler.raw_crawler" "$GLUE_CRAWLER_RAW"
tf_import_if_missing "aws_glue_crawler.curated_crawler" "$GLUE_CRAWLER_CURATED"
tf_import_if_missing "aws_lambda_function.clientes_api" "$LAMBDA_FN_NAME"
tf_import_if_missing "aws_lambda_permission.allow_apigw" "$LAMBDA_PERMISSION_ID"

# 3) plan/apply
tf "terraform plan"
tf "terraform apply -auto-approve"

# 4) Pipeline Glue (AWS CLI no host)
RAW="$GLUE_CRAWLER_RAW"
CURATED="$GLUE_CRAWLER_CURATED"
JOB="$GLUE_JOB_NAME"
BUCKET="$S3_BUCKET"

echo "[CHECK] Verificando se crawlers/job existem no Glue (região=$AWS_REGION)..."
awsr glue get-crawler --name "$RAW" >/dev/null
awsr glue get-crawler --name "$CURATED" >/dev/null
awsr glue get-job --job-name "$JOB" >/dev/null

wait_crawler() {
  local crawler_name="$1"
  echo "Waiting crawler: $crawler_name ..."

  while true; do
    state=$(awsr glue get-crawler --name "$crawler_name" --query 'Crawler.State' --output text)
    [ "$state" = "READY" ] && break
    sleep 10
  done

  last=$(awsr glue get-crawler --name "$crawler_name" --query 'Crawler.LastCrawl.Status' --output text)
  echo "Crawler $crawler_name LastCrawl.Status: $last"

  if [ "$last" != "SUCCEEDED" ]; then
    echo "ERROR: crawler $crawler_name terminou sem SUCCEEDED (status=$last)"
    exit 1
  fi
}

wait_job() {
  local job_name="$1"
  local run_id="$2"

  echo "Waiting Glue job $job_name run $run_id ..."
  while true; do
    status=$(awsr glue get-job-run \
      --job-name "$job_name" \
      --run-id "$run_id" \
      --query 'JobRun.JobRunState' --output text)

    echo "Job status: $status"

    if [ "$status" = "SUCCEEDED" ]; then
      break
    elif [ "$status" = "FAILED" ] || [ "$status" = "STOPPED" ] || [ "$status" = "TIMEOUT" ]; then
      err=$(awsr glue get-job-run --job-name "$job_name" --run-id "$run_id" --query 'JobRun.ErrorMessage' --output text || true)
      echo "ERROR: Glue job terminou com status $status"
      echo "ErrorMessage: $err"
      exit 1
    fi

    sleep 20
  done
}

awsr glue start-crawler --name "$RAW" || true
wait_crawler "$RAW"

run_id=$(awsr glue start-job-run \
  --job-name "$JOB" \
  --arguments "{\"--S3_BUCKET\":\"$BUCKET\"}" \
  --query 'JobRunId' --output text)

wait_job "$JOB" "$run_id"

awsr glue start-crawler --name "$CURATED" || true
wait_crawler "$CURATED"

echo "Done: crawlers + job executed."

API_URL=$(docker exec -i "$TERRAFORM_CONTAINER" sh -lc "cd '$TF_IAC_DIR' && terraform output -raw clientes_api_base_url" 2>/dev/null | tr -d '\r' || true)
if [ -n "${API_URL:-}" ]; then
  echo "API URL: $API_URL"
fi

