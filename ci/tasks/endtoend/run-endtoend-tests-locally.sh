#!/usr/bin/env bash

set -euo pipefail

function usage {
  echo "Run end to end tests locally"
  echo
  echo "$0 <card|products|zap>"
  echo
  echo "Example to run the card endtoend tests:"
  echo "    $0 card"
  echo
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

if [ "$1" != "card" ] && [ "$1" != "products" ] && [ "$1" != "zap" ]; then
  usage
  exit 1
fi

export END_TO_END_TEST_SUITE=$1

if [ $(uname -p) == "arm" ]; then
  echo "WARNING: The actual end to end tests do not work on an ARM CPU. However everything else can be started up."
  echo
  read -p "Press enter to continue: "
fi

echo "Going to run the ${END_TO_END_TEST_SUITE} tests. To change this 'export END_TO_END_TEST_SUITE=<suite>' where suite is card, products, or zap"

export END_TO_END_JAVA_OPTS="-Xms1G -Xmx2G"
export END_TO_END_MEM_LIMIT="1G"
export repo_publicapi=governmentdigitalservice/pay-publicapi
export repo_frontend=governmentdigitalservice/pay-frontend
export repo_reverse_proxy=governmentdigitalservice/pay-reverse_proxy
export repo_adminusers=governmentdigitalservice/pay-adminusers
export repo_selfservice=governmentdigitalservice/pay-selfservice
export repo_reverse_proxy=governmentdigitalservice/pay-reverse_proxy
export repo_connector=governmentdigitalservice/pay-connector
export repo_ledger=governmentdigitalservice/pay-ledger
export repo_publicauth=governmentdigitalservice/pay-publicauth
export repo_stubs=governmentdigitalservice/pay-stubs
export repo_reverse_proxy=governmentdigitalservice/pay-reverse-proxy
export repo_cardid=governmentdigitalservice/pay-cardid
export repo_endtoend=governmentdigitalservice/pay-endtoend

echo "|========================================================================="
echo "| Running docker compose up"
echo "|========================================================================="
docker-compose -f "${END_TO_END_TEST_SUITE}/docker-compose.yml" up -d --quiet-pull --no-recreate

echo "|========================================================================="
echo "| Sleeping for 10 seconds to allow everything to come to life"
echo "|========================================================================="
for i in seq 10 1; do
  echo -n "$i "
  sleep 1
done
echo
echo "|========================================================================="
echo "| Displaying running docker containers"
echo "|========================================================================="
docker-compose -f "${END_TO_END_TEST_SUITE}/docker-compose.yml" ps

echo "|========================================================================="
echo "| Getting endtoend container id"
echo "|========================================================================="
endtoend=$(docker ps -aqf "name=${END_TO_END_TEST_SUITE}-endtoend")

if [ -z "$endtoend" ]; then
  echo "Couldn't find endtoend container"
  exit 1
else
  echo "Endtoend container ID is ${endtoend}"
fi

echo "|========================================================================="
echo "| Executing ${END_TO_END_TEST_SUITE} end to end tests"
echo "|========================================================================="
docker exec "${endtoend}" "/app/bin/e2e-${END_TO_END_TEST_SUITE}"
