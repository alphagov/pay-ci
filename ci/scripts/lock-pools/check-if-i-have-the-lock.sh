#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

LOCK_STATUS=$(cat lock-status/status)
LOCK_TEAM=$(cat lock-status/team)
LOCK_PIPELINE=$(cat lock-status/pipeline)
LOCK_JOB=$(cat lock-status/job)
LOCK_BUILD_NAME=$(cat lock-status/build-number)

if [ "$LOCK_STATUS" = "unclaimed" ]; then
  echo "Lock is unclaimed"
  exit 0
fi

if [ "$LOCK_TEAM" = "$BUILD_TEAM" ] && [ "$LOCK_PIPELINE" = "$BUILD_PIPELINE" ] && [ "$LOCK_JOB" = "$BUILD_JOB" ] && [ "$LOCK_BUILD_NAME" = "$BUILD_NAME" ]; then
  echo "This build of this job is the lock claimint! Exiting with an error to indicate deadlock"
  exit 1
fi

echo "The lock is claimed, but not by me"
