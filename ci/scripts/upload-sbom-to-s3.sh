#!/bin/ash
# shellcheck shell=dash

# Script for uploading SBOM data to S3"

DATE=$(date -I)

echo "Uploading SBOM files..."
aws s3 cp sbom-data/ s3://govuk-pay-sbom-deploy/"${DATE}"_docker_sbom --recursive
