#!/usr/bin/env bash

set -o errexit \
    -o nounset

export PASSWORD_STORE_DIR="$(dirname "$0")"

usage="Usage: $0 <name> <path_in_password_store>"
name="${1?:$usage}"
path="${2?:$usage}"

secret="$(pass "$path")"
test -n "$secret"

docker-compose exec localstack \
  awslocal ssm put-parameter \
  --name "$name" \
  --value "$secret" \
  --type SecretString \
  --overwrite
