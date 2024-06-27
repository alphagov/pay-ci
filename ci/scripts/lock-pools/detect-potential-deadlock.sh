#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

if [ -z "${POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES:-}" ]; then
  echo "Error: The env var POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES is not set."
  exit 1
fi

LOCK_STATUS=$(cat lock-status/status)
DATE=$(cat lock-status/date)
LOCK_CLAIMED_TIMESTAMP=$(cat lock-status/timestamp)

if [ "$LOCK_STATUS" = "unclaimed" ]; then
  echo "Lock is unclaimed, nothing to do"
  exit 0
fi

CURRENT_TIMESTAMP=$(date +%s)

POTENTIAL_DEADLOCK_TIMEOUT_IN_SECONDS=$((POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES * 60))
POTENTIAL_DEADLOCK_IF_CLAIMED_BEFORE=$((CURRENT_TIMESTAMP - POTENTIAL_DEADLOCK_TIMEOUT_IN_SECONDS))
IGNORE_POTENTIAL_DEADLOCK_BEFORE_IN_MINUTES=$((POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES * 2))
IGNORE_POTENTIAL_DEADLOCK_BEFORE=$((CURRENT_TIMESTAMP - (POTENTIAL_DEADLOCK_TIMEOUT_IN_SECONDS * 2)))

if [ "$LOCK_CLAIMED_TIMESTAMP" -gt "$POTENTIAL_DEADLOCK_IF_CLAIMED_BEFORE" ]; then
  echo "Lock was claimed at $DATE, but this is less than $POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES minutes ago, nothing to do."
  exit 0
fi

if [ "$LOCK_CLAIMED_TIMESTAMP" -lt "$IGNORE_POTENTIAL_DEADLOCK_BEFORE" ]; then
  echo "Lock was claimed at $DATE, this is more than $IGNORE_POTENTIAL_DEADLOCK_BEFORE_IN_MINUTES minutes ago, ignoring in the knowledge the auto-deadlock resolution will happen"
  exit 0
fi

echo "Lock was claimed at $DATE, which is more than $POTENTIAL_DEADLOCK_TIMEOUT_IN_MINUTES minutes ago"
echo "POTENTIAL DEADLOCK DETECTED"
exit 1
