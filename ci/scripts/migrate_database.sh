#!/bin/bash
set -o errexit -o nounset

: "${APP_NAME:?APP_NAME is required (e.g. card-connector)}"
: "${APP_PACKAGE:?APP_PACKAGE is required (e.g. uk.gov.pay.connector.ConnectorApplication)}"

function createCommandFor() {
  echo "source <(jq -r .\"start_command\" /home/vcap/staging_info.yml | sed 's/server/${1}/g' | sed 's/eval exec/eval/g')"
}

TASK_COMMAND=$(createCommandFor "db migrate")

if [[ "$APP_NAME" == 'adminusers' ]]; then
  INITIAL_MIGRATION=$(createCommandFor migrateToInitialDbState);
  TASK_COMMAND="${INITIAL_MIGRATION} && ${TASK_COMMAND}";
fi

cf run-task "${APP_NAME}" --command "${TASK_COMMAND}" --name "${APP_NAME}-db-migration"

echo "You can view the raw logs using: cf logs ${APP_NAME} --recent"
echo "Fetching task logs:"

cf logs "${APP_NAME}" | sed '/Exit status/q' > migration.log

EXIT_CODE=$(sed -En 's/.*Exit status ([0-9]*)/\1/p' migration.log)

awk '$4 ~ /(\[APP\/TASK\/)*/' migration.log | grep -o '{.*}' | jq '.message' -r

if [ "$EXIT_CODE" != 0 ]
then
  cat migration.log
  exit 1
fi
