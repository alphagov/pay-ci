#!/bin/sh

cat > /tmp/sqs_attributes.json <<EOF
{
  "VisibilityTimeout": "3600",
  "DelaySeconds": "0",
  "ReceiveMessageWaitTimeSeconds": "0"
}
EOF

echo "|======================================================================="
echo "| Creating SQS queues"
echo "|======================================================================="
for QUEUE in \
    connector_tasks_queue \
    pay_capture_queue \
    pay_event_queue \
    payout_reconcile_queue \
    webhooks-events-subscriber-queue
do
  echo "---------------------"
  echo "Creating queue $QUEUE"
  echo "---------------------"
  aws sqs create-queue \
    --queue-name "$QUEUE" \
    --attributes file:///tmp/sqs_attributes.json \
    --endpoint-url=http://localhost:4566 \
    --region=eu-west-1
  echo "---------------------"
  echo
done

echo "|======================================================================="
echo "| Creating SNS topics"
echo "|======================================================================="
for TOPIC in \
    card-payment-dispute-events-topic \
    card-payment-events-topic
do
  echo "---------------------"
  echo "Creating topic $TOPIC"
  echo "---------------------"
  aws sns create-topic \
    --name "$TOPIC" \
    --endpoint-url=http://localhost:4566 \
    --region=eu-west-1
  echo "---------------------"
  echo
done

echo "|======================================================================="
echo "| Subscribing webhooks SQS queue to relevant SNS topics"
echo "|======================================================================="
for TOPIC in \
    card-payment-dispute-events-topic \
    card-payment-events-topic
do
  echo
  echo "---------------------"
  echo "Subscribing webhooks-events-subscriber-queue to topic $TOPIC"
  echo "---------------------"
  aws sns subscribe \
    --topic-arn "arn:aws:sns:eu-west-1:000000000000:$TOPIC" \
    --protocol sqs \
    --notification-endpoint arn:aws:sns:eu-west-1:000000000000:webhooks-events-subscriber-queue \
    --endpoint-url=http://localhost:4566 \
    --region=eu-west-1
  echo
  echo
done
