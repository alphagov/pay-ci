#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

TOTAL_WAIT_TIME_IN_MINUTES=$((MAX_ATTEMPTS * 15 / 60))

RDS_INSTANCE_NAME="test-perf-1-connector-rds-0"

DESCRIBE_DB_INSTANCE_OUTPUT=$(mktemp)

for ATTEMPT in $(seq 1 "${MAX_ATTEMPTS}"); do
  aws rds describe-db-instances --db-instance-identifier "$RDS_INSTANCE_NAME" > "$DESCRIBE_DB_INSTANCE_OUTPUT"

  DB_STATUS=$(jq -r '.DBInstances[0].DBInstanceStatus' < "$DESCRIBE_DB_INSTANCE_OUTPUT")

  if [ "$DB_STATUS" = "available" ]; then
    echo "RDS instance $RDS_INSTANCE_NAME is available"
    exit 0
  elif [ "${DB_STATUS}" = "stopped" ]; then
    echo "Error: DB instance $RDS_INSTANCE_NAME is 'stopped'"
    echo "Perhaps you need to scale up the databases?"
    exit 1
  elif [ "${DB_STATUS}" = "backing-up" ] ||
       [ "${DB_STATUS}" = "configuring-enhanced-monitoring" ] ||
       [ "${DB_STATUS}" = "rebooting" ] ||
       [ "${DB_STATUS}" = "starting" ]; then
    echo "The RDS instance ${RDS_INSTANCE_NAME} is currently in state ${DB_STATUS}. We need to wait for that to complete."
  else
    echo "RDS instance ${RDS_INSTANCE_NAME} is not in a suitable state." \
      "It's currently in ${DB_STATUS}, manual intervention will be required to resolve this."
    exit 1
  fi

  echo "Waiting 15 seconds before checking again. Attempt ${ATTEMPT}/${MAX_ATTEMPTS}"
  sleep 15
done

echo "RDS instance ${RDS_INSTANCE_NAME} did not reach the available state within ${TOTAL_WAIT_TIME_IN_MINUTES} minutes"
exit 1
