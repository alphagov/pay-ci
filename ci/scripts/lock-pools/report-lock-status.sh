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

cd "$LOCK_NAME" >> /dev/null 2>&1

print_and_write_lock_status() {
  # Args:
  #  $1: The status of the lock
  LOCK_STATUS="$1"
  
  # FIXME: REMOVE THIS
  echo "Full commit message":
  git log -n 1 --date raw -n 1 "${LOCK_STATUS}/${LOCK_NAME}-lock"
  echo

  COMMIT_DATE=$(git log -n 1 "${LOCK_STATUS}/${LOCK_NAME}-lock" | grep "^Date:" | sed -E 's/^Date:\s+//')
  COMMIT_TIMESTAMP=$(git log --date raw -n 1 "${LOCK_STATUS}/${LOCK_NAME}-lock" | grep "^Date:" | sed -E 's/^Date:\s+([0-9]+) .*/\1/')
  COMMIT_MESSAGE=$(git log -n 1 "${LOCK_STATUS}/${LOCK_NAME}-lock" | tail -n 1)

  # Commit message format:
  # <team>/<pipeline>/<job> build <build_number> <claiming|unclaiming>: <lock_name>-lock
  FULL_CLAIMANT_INFO=$(echo "$COMMIT_MESSAGE" | cut -f 1 -d " ")
  CONCOURSE_TEAM=$(echo "$FULL_CLAIMANT_INFO" | cut -f 1 -d "/")
  CONCOURSE_PIPELINE=$(echo "$FULL_CLAIMANT_INFO" | cut -f 2 -d "/")
  CONCOURSE_JOB=$(echo "$FULL_CLAIMANT_INFO" | cut -f 3 -d "/")
  BUILD_NUMBER=$(echo "$COMMIT_MESSAGE" | sed -E 's/.* build ([0-9]+) (un)?claiming: .*/\1/')

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
  echo

  cd ../lock-status
  echo "claimed" > status
  echo "$CONCOURSE_TEAM" > team
  echo "$CONCOURSE_PIPELINE" > pipeline
  echo "$CONCOURSE_JOB" > job
  echo "$BUILD_NUMBER" > build-number
  echo "$COMMIT_DATE" > "date"
  echo "$COMMIT_TIMESTAMP" > timestamp
}

if [ -f "unclaimed/${LOCK_NAME}-lock" ]; then
  print_and_write_lock_status "unclaimed"
elif [ -f "claimed/${LOCK_NAME}-lock" ]; then
  print_and_write_lock_status "claimed"
else
  echo "Error! Couldn't find lock file '${LOCK_NAME}-lock' in either claimed or unclaimed directories"
  exit 1
fi
