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

aws glue start-crawler --name "$RAW" || true
echo "Waiting RAW crawler..."
while true; do
  state=$(aws glue get-crawler --name "$RAW" --query 'Crawler.State' --output text)
  [ "$state" = "READY" ] && break
  sleep 10
done

run_id=$(aws glue start-job-run \
  --job-name "$JOB" \
  --arguments "{\"--S3_BUCKET\":\"$BUCKET\"}" \
  --query 'JobRunId' --output text)

echo "Waiting Glue job $run_id..."
aws glue wait job-run-succeeded --job-name "$JOB" --run-id "$run_id"

aws glue start-crawler --name "$CURATED" || true
echo "Waiting CURATED crawler..."
while true; do
  state=$(aws glue get-crawler --name "$CURATED" --query 'Crawler.State' --output text)
  [ "$state" = "READY" ] && break
  sleep 10
done

echo "Done: crawlers + job executed."
