#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"

docker exec -it terraform sh -lc 'cd /iac && terraform init'
docker exec -it terraform sh -lc 'cd /iac && terraform fmt -recursive'
docker exec -it terraform sh -lc 'cd /iac && terraform validate'
docker exec -it terraform sh -lc 'cd /iac && terraform plan'
docker exec -it terraform sh -lc 'cd /iac && terraform apply'