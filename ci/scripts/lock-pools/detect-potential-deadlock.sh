#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

LOCK_STATUS=$(cat lock-status/status)
DATE=$(cat lock-status/date)
LOCK_CLAIMED_TIMESTAMP=$(cat lock-status/timestamp)

## FIXME - uncomment this
### if [ "$LOCK_STATUS" = "unclaimed" ]; then
###   echo "Lock is unclaimed, nothing to do"
###   exit 0
### fi

CURRENT_TIMESTAMP=$(date +%s)

POTENTIAL_DEADLOCK_TIMEOUT_IN_SECONDS=900 # 15 minutes

if [ "$CURRENT_TIMESTAMP" -lt "$((LOCK_CLAIMED_TIMESTAMP + POTENTIAL_DEADLOCK_TIMEOUT_IN_SECONDS))" ]; then
  echo "Lock was claimed at $DATE, but this is less than 15 minutes ago, nothing to do."
  exit 0
fi

echo "Lock was claimed at $DATE, which is more than 15 minutes ago"
echo "POTENTIAL DEADLOCK DETECTED"
exit 1
