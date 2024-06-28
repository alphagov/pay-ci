#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

if [ -z "${LOCK_NAME:-}" ]; then
  echo "Error: The env var LOCK_NAME must be set"
  exit 1
fi

if [ ! -d "$LOCK_NAME" ]; then
  echo "Error: Couldn't find lock with name $LOCK_NAME"
  exit 1
fi

print_and_write_lock_status() {
  # Args:
  #  $1: The status of the lock
  local LOCK_STATUS="$1"

  local LOCK_FILE_PATH="${LOCK_NAME}/${LOCK_STATUS}/${LOCK_NAME}-lock"
  
  local COMMIT_DATE=$(git log -n 1 "$LOCK_FILE_PATH" | grep "^Date:" | sed -E 's/^Date:\s+//')
  local COMMIT_TIMESTAMP=$(git log --date raw -n 1 "$LOCK_FILE_PATH" | grep "^Date:" | sed -E 's/^Date:\s+([0-9]+) .*/\1/')
  local COMMIT_MESSAGE=$(git log -n 1 "$LOCK_FILE_PATH" | tail -n 1 | sed -E 's/^\s+//')

  # Commit message format:
  # <team>/<pipeline>/<job> build <build_number> <claiming|unclaiming>: <lock_name>-lock
  local FULL_CLAIMANT_INFO=$(echo "$COMMIT_MESSAGE" | cut -f 1 -d " ")
  local CONCOURSE_TEAM=$(echo "$FULL_CLAIMANT_INFO" | cut -f 1 -d "/")
  local CONCOURSE_PIPELINE=$(echo "$FULL_CLAIMANT_INFO" | cut -f 2 -d "/")
  local CONCOURSE_JOB=$(echo "$FULL_CLAIMANT_INFO" | cut -f 3 -d "/")
  local BUILD_NUMBER=$(echo "$COMMIT_MESSAGE" | sed -E 's/.* build ([0-9]+) (un)?claiming: .*/\1/')

  echo
  if [ "$LOCK_STATUS" = "claimed" ]; then
    echo "Lock is claimed by:"
  else
    echo "Lock is unclaimed, it was released by:"
  fi
  echo "          Team: $CONCOURSE_TEAM"
  echo "      Pipeline: $CONCOURSE_PIPELINE"
  echo "           Job: $CONCOURSE_JOB"
  echo "  Build Number: $BUILD_NUMBER"
  echo "          Date: $COMMIT_DATE"
  echo "           URL: https://pay-cd.deploy.payments.service.gov.uk/teams/$CONCOURSE_TEAM/pipelines/$CONCOURSE_PIPELINE/jobs/$CONCOURSE_JOB/builds/$BUILD_NUMBER"
  echo

  echo "$LOCK_STATUS" > ../lock-status/status
  echo "$CONCOURSE_TEAM" > ../lock-status/team
  echo "$CONCOURSE_PIPELINE" > ../lock-status/pipeline
  echo "$CONCOURSE_JOB" > ../lock-status/job
  echo "$BUILD_NUMBER" > ../lock-status/build-number
  echo "$COMMIT_DATE" > ../lock-status/date
  echo "$COMMIT_TIMESTAMP" > ../lock-status/timestamp
} >&2

if [ -f "${LOCK_NAME}/unclaimed/${LOCK_NAME}-lock" ]; then
  print_and_write_lock_status "unclaimed"
elif [ -f "${LOCK_NAME}/claimed/${LOCK_NAME}-lock" ]; then
  print_and_write_lock_status "claimed"
else
  echo "Error! Couldn't find lock file '${LOCK_NAME}-lock' in either claimed or unclaimed directories"
  exit 1
fi
