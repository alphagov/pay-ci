#!/bin/bash
set -o errexit -o nounset

: ${APP_NAME:?APP_NAME is required (e.g. card-connector)}
: ${APP_PACKAGE:?APP_PACKAGE is required (e.g. uk.gov.pay.connector.ConnectorApplication)}

function createCommandFor() {
  echo "/home/vcap/app/.java-buildpack/open_jdk_jre/bin/java \
  -Djava.security.properties=/home/vcap/app/.java-buildpack/java_security/java.security -Xms512m -Xmx1G \
  -cp /home/vcap/app/.:/home/vcap/app/.java-buildpack/client_certificate_mapper/client_certificate_mapper-1.11.0_RELEASE.jar:\
  /home/vcap/app/.java-buildpack/postgresql_jdbc/postgresql_jdbc-42.2.9.jar:\
  /home/vcap/app/.java-buildpack/container_security_provider/container_security_provider-1.16.0_RELEASE.jar \
  ${APP_PACKAGE} db ${1} /home/vcap/app/config/config.yaml"
}

TASK_COMMAND=$(createCommandFor migrate)

if [[ "$APP_NAME" == 'adminusers' ]]; then
  INITIAL_MIGRATION=$(createCommandFor migrateToInitialDbState);
  TASK_COMMAND="${INITIAL_MIGRATION} && ${TASK_COMMAND}";
fi

cf run-task ${APP_NAME} "${TASK_COMMAND}" --name "${APP_NAME}-db-migration"

echo "You can view the raw logs using: cf logs ${APP_NAME} --recent"
echo "Fetching task logs:"

cf logs ${APP_NAME} | sed '/Exit status/q' > migration.log

EXIT_CODE=$(cat migration.log | sed -En 's/.*Exit status ([0-9]*)/\1/p')

cat migration.log | awk '$4 ~ /(\[APP\/TASK\/)*/' | grep -o '{.*}' | jq '.message' -r

if [ $EXIT_CODE != 0 ]
then
  cat migration.log
  exit 1
fi
