#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

TASK_ID=$(cat run-cleanup-task/id)

PREVIOUS_LOG_STREAM_FORWARD_TOKEN="PREVIOUS"
NEXT_LOG_STREAM_FORWARD_TOKEN=""
LOG_OUTPUT_TMPFILE=$(mktemp)

get_next_log_events() {
  if [ -n "$NEXT_LOG_STREAM_FORWARD_TOKEN" ]; then
    aws logs get-log-events \
      --start-from-head \
      --log-group-name "test-perf-1__cleanup_task" \
      --log-stream-name "cleanup_task/cleanup/$TASK_ID" \
      --next-token "$NEXT_LOG_STREAM_FORWARD_TOKEN" \
      >"$LOG_OUTPUT_TMPFILE"
  else
    aws logs get-log-events \
      --start-from-head \
      --log-group-name "test-perf-1__cleanup_task" \
      --log-stream-name "cleanup_task/cleanup/$TASK_ID" \
      >"$LOG_OUTPUT_TMPFILE"
  fi

  PREVIOUS_LOG_STREAM_FORWARD_TOKEN="$NEXT_LOG_STREAM_FORWARD_TOKEN"
  NEXT_LOG_STREAM_FORWARD_TOKEN=$(jq -r '.nextForwardToken' <"$LOG_OUTPUT_TMPFILE")
}

get_next_log_events

jq -r '.events[].message' <"$LOG_OUTPUT_TMPFILE"

while true; do
  get_next_log_events

  if [ "$PREVIOUS_LOG_STREAM_FORWARD_TOKEN" = "$NEXT_LOG_STREAM_FORWARD_TOKEN" ]; then
    break
  fi

  jq -r '.events[].message' <"$LOG_OUTPUT_TMPFILE"
done
