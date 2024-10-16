#!/bin/bash

set -euo pipefail

function db_instance_state() {
  aws rds describe-db-instances --db-instance-identifier "${RDS_INSTANCE_NAME}" --query "DBInstances[0].DBInstanceStatus" --output text
}

TOTAL_WAIT_TIME_IN_MINUTES=$((MAX_ATTEMPTS * 15 / 60))

for ATTEMPT in $(seq 1 "${MAX_ATTEMPTS}"); do
  CURRENT_STATE=$(db_instance_state)

  if [ "${CURRENT_STATE}" == "stopped" ]; then
    echo "The RDS instance ${RDS_INSTANCE_NAME} is stopped"
    exit 0
  elif [ "${CURRENT_STATE}" == "available" ]; then
    echo "Stopping RDS instance ${RDS_INSTANCE_NAME}"
    aws rds stop-db-instance --db-instance-identifier "${RDS_INSTANCE_NAME}" >> /dev/null
  elif [ "${CURRENT_STATE}" == "stopping" ]; then
    echo "The RDS instance ${RDS_INSTANCE_NAME} is currently stopping."
  elif [ "${CURRENT_STATE}" == "backing-up" ] || [ "${CURRENT_STATE}" == "configuring-enhanced-monitoring" ] || [ "${CURRENT_STATE}" == "rebooting" ]; then
    echo "The RDS instance ${RDS_INSTANCE_NAME} is currently in state ${CURRENT_STATE}. We need to wait for that to complete."
  else
    echo "RDS instance ${RDS_INSTANCE_NAME} is not in a state which can be stopped. " \
      "It's currently in state ${CURRENT_STATE}, manual intervention will be required"
    exit  1
  fi

  echo "Waiting 15 seconds before checking again. Attempt ${ATTEMPT}/${MAX_ATTEMPTS}"

  sleep 15
done

echo "RDS instance ${RDS_INSTANCE_NAME} did not reach the stopped state within ${TOTAL_WAIT_TIME_IN_MINUTES} minutes"
exit 1
