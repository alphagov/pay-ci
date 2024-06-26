#!/usr/bin/env ash
# shellcheck shell=dash

set -euo pipefail

CLEANUP_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=test-perf-1-perf-test-cleanup-task" \
  --query 'SecurityGroups[0].GroupId' \
  --output text
)

BASE_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=test-perf-1-sg-base" \
  --query 'SecurityGroups[0].GroupId' \
  --output text
)

if [ -z "${CLEANUP_SG_ID}" ] || [ "${CLEANUP_SG_ID}" = "null" ] ; then
  echo "Error: Couldn't get the security group id of SG: test-perf-1-perf-test-cleanup-task"
  exit 1
fi

if [ -z "${BASE_SG_ID}" ] || [ "${BASE_SG_ID}" = "null" ] ; then
  echo "Error: Couldn't get the security group id of SG: test-perf-1-sg-base"
  exit 1
fi

CONNECTOR_SUBNET_ID=$(aws ec2 describe-subnets \
  --filter "Name=tag:Name,Values=test-perf-1-connector-eu-west-1a" \
  --query 'Subnets[0].SubnetId' \
  --output text
)

if [ -z "${CONNECTOR_SUBNET_ID}" ] || [ "${CONNECTOR_SUBNET_ID}" = "null" ] ; then
  echo "Error: Couldn't get the subnet ID of subnet test-perf-1-connector-eu-west-1a"
  exit 1
fi

CONTAINER_OVERRIDES_JSON_FILE=$(mktemp)

cat >"$CONTAINER_OVERRIDES_JSON_FILE" <<EOF
{
  "containerOverrides": [
    {
      "name": "cleanup",
      "command": ["/ci/cleanup-test-perf-1.sh"]
    }
  ]
}
EOF

TASK_ARN=$(aws ecs run-task \
  --task-definition test-perf-1_perf-test-cleanup \
  --cluster test-perf-1-fargate \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$CONNECTOR_SUBNET_ID],securityGroups=[$CLEANUP_SG_ID,$BASE_SG_ID],assignPublicIp=DISABLED}" \
  --overrides "file://${CONTAINER_OVERRIDES_JSON_FILE}" \
  --query 'tasks[0].containers[0].taskArn' \
  --output text
)

if [ -z "${TASK_ARN}" ] || [ "${TASK_ARN}" = "null" ] ; then
  echo "Error: Couldn't start the task test-perf-1_perf-test-cleanup"
  exit 1
fi

TASK_ID=$(echo -n "$TASK_ARN" | sed -E s@^.*/@@)

echo "Task started"
echo "  ARN: $TASK_ARN"
echo "   ID: $TASK_ID"
echo

echo -n "$TASK_ARN" > run-cleanup-task/arn
echo -n "$TASK_ID" > run-cleanup-task/id
