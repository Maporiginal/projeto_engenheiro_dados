#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply