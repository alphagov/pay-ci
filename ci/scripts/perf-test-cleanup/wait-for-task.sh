#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

TASK_ARN=$(cat run-cleanup-task/arn)

echo "Waiting for task to complete"
aws ecs wait tasks-stopped --cluster test-perf-1-fargate --tasks "$TASK_ARN"

TMP_FILE=$(mktemp)
aws ecs describe-tasks --cluster test-perf-1-fargate  --tasks "$TASK_ARN" > "$TMP_FILE"

TASK_STATUS=$(jq '.tasks[0].containers[0].lastStatus' <"$TMP_FILE")
TASK_EXIT_CODE=$(jq '.tasks[0].containers[0].exitCode' <"$TMP_FILE")

echo
echo "Task finished:"
echo "  Final Status: $TASK_STATUS"
echo "  Exit Code: $TASK_EXIT_CODE"

exit "$TASK_EXIT_CODE"
