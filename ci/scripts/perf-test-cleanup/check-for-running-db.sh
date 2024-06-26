#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

DESCRIBE_DB_INSTANCE_OUTPUT=$(mktemp)

aws-vault exec test -- \
  aws rds describe-db-instances \
  --db-instance-identifier test-perf-1-connector-rds-0 \
  > "$DESCRIBE_DB_INSTANCE_OUTPUT"

DB_STATUS=$(jq -r '.DBInstances[0].DBInstanceStatus' < "$DESCRIBE_DB_INSTANCE_OUTPUT")

if [ "$DB_STATUS" != "available" ]; then
  echo "Error: DB Instance test-perf-1-connector-rds-0 is not in 'available' state"
  echo "Perhaps you need to scale up the databases?"
  exit 1
fi

echo "Database is available"
