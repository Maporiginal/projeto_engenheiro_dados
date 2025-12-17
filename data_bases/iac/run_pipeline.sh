#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# 1) Provisiona infra
docker exec -it terraform sh -lc 'cd /iac && terraform init'
docker exec -it terraform sh -lc 'cd /iac && terraform fmt -recursive'
docker exec -it terraform sh -lc 'cd /iac && terraform validate'
docker exec -it terraform sh -lc 'cd /iac && terraform plan'
docker exec -it terraform sh -lc 'cd /iac && terraform apply -auto-approve'

# 2) Executa pipeline Glue (precisa AWS CLI no host)
RAW="lab-raw-crawler"
CURATED="lab-curated-crawler"
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

wait_job() {
  local job_name="$1"
  local run_id="$2"

  echo "Waiting Glue job $job_name run $run_id ..."
  while true; do
    status=$(aws glue get-job-run \
      --job-name "$job_name" \
      --run-id "$run_id" \
      --query 'JobRun.JobRunState' --output text)

    echo "Job status: $status"

    if [ "$status" = "SUCCEEDED" ]; then
      break
    elif [ "$status" = "FAILED" ] || [ "$status" = "STOPPED" ] || [ "$status" = "TIMEOUT" ]; then
      echo "ERROR: Glue job terminou com status $status"
      exit 1
    fi

    sleep 20
  done
}

# RAW crawler
aws glue start-crawler --name "$RAW" || true
wait_crawler "$RAW"

# Glue job
run_id=$(aws glue start-job-run \
  --job-name "$JOB" \
  --arguments "{\"--S3_BUCKET\":\"$BUCKET\"}" \
  --query 'JobRunId' --output text)

wait_job "$JOB" "$run_id"

# CURATED crawler
aws glue start-crawler --name "$CURATED" || true
wait_crawler "$CURATED"

echo "Done: crawlers + job executed."

# -------- Testar API (Lambda + API Gateway) --------
API_URL=$(docker exec -it terraform sh -lc 'cd /iac && terraform output -raw clientes_api_base_url' | tr -d '\r')
echo "API URL: $API_URL"

# teste básico (troque o nome se quiser)
HTTP_CODE=$(curl -s -o /tmp/api_out.json -w "%{http_code}" "$API_URL/clientes?nome=Carla")

echo "API HTTP CODE: $HTTP_CODE"
cat /tmp/api_out.json
echo ""

if [ "$HTTP_CODE" != "200" ]; then
  echo "ERROR: API não respondeu 200"
  exit 1
fi