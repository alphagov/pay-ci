#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

LOCK_STATUS=$(cat lock-status/status)
LOCK_DATE=$(cat lock-status/date)
LOCK_TEAM=$(cat lock-status/team)
LOCK_PIPELINE=$(cat lock-status/pipeline)
LOCK_JOB=$(cat lock-status/job)
LOCK_BUILD_NUMBER=$(cat lock-status/build-number)

if [ "$LOCK_STATUS" = "unclaimed" ]; then
  echo "Lock is unclaimed, nothing to do"
  exit 0
fi

fly -t "${LOCK_TEAM}" login \
  -c "https://pay-cd.deploy.payments.service.gov.uk/" \
  -u "${LOCK_TEAM}" \
  -p "${FLY_PASSWORD}" \

BUILD_DETAILS_TMPFILE=$(mktemp)

fly -t "${LOCK_TEAM}" builds --job "${LOCK_PIPELINE}/${LOCK_JOB}" --json > "$BUILD_DETAILS_TMPFILE"

BUILD_STATUS=$(jq -r ".[] | select(.name == \"${LOCK_BUILD_NUMBER}\") | .status" <"$BUILD_DETAILS_TMPFILE")

if [ "$BUILD_STATUS" = "failed" ] || [ "$BUILD_STATUS" = "errored" ] || [ "$BUILD_STATUS" = "aborted" ]; then
  echo "The lock was claimed at $LOCK_DATE by $LOCK_TEAM/$LOCK_PIPELINE/$LOCK_JOB build number $LOCK_BUILD_NUMBER but the build is in the '$BUILD_STATUS' state"
  echo "This means the lock is deadlocked and it needs force unlocking"
  return 1
fi

echo "Lock is claimed by job $LOCK_TEAM/$LOCK_PIPELINE/$LOCK_JOB build number $LOCK_BUILD_NUMBER, this job has status '$BUILD_STATUS'. Nothing to do"
