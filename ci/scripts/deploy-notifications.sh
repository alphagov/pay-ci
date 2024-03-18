#!/bin/ash
# shellcheck shell=dash
set -euo pipefail

cd "pay-infra/provisioning/terraform/deployments/${ACCOUNT}/${ENVIRONMENT}/microservices_v2/notifications"

terraform init

terraform apply \
  -var notifications_image_tag="${APPLICATION_IMAGE_TAG}" \
  -auto-approve
