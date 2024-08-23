#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

TERRAFORM_ROOT=${TERRAFORM_ROOT:-./pay-infra}

if [ ! -d "$TERRAFORM_ROOT" ]; then
  echo "Error, the terraform root directory specified '$TERRAFORM_ROOT' does not exist"
  exit 1
fi

if [ ! -d "terraform-version" ]; then
  echo "Error: The terraform-version output directory is missing, you probably need to specify it as an output in the task"
  exit 1
fi

CURRENT_PATH="$TERRAFORM_ROOT"

while [ ! -f "$CURRENT_PATH/.terraform-version" ]; do
  echo "$CURRENT_PATH/.terraform-version does not exist"

  if [ "$(basename "$CURRENT_PATH")" = "pay-infra" ]; then
    echo "Error, checked all directories from $TERRAFORM_ROOT upwards to pay-infra and did not find a .terraform-version file"
    exit 1
  fi

  CURRENT_PATH=$(dirname "$CURRENT_PATH")
done

echo "$CURRENT_PATH/.terraform-version found"

tee -a terraform-version/.terraform-version < "$CURRENT_PATH/.terraform-version"
