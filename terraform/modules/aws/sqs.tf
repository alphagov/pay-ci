resource "aws_sqs_queue" "capture" {
  name                       = "${var.environment}-capture"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 259200
  receive_wait_time_seconds  = 20
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.capture_dead_letter.arn
    maxReceiveCount     = 2
  })
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

resource "aws_sqs_queue" "capture_dead_letter" {
  name              = "${var.environment}-capture-dead-letter"
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

resource "aws_sqs_queue" "payment_event" {
  name                       = "${var.environment}-payment-event"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 259200
  receive_wait_time_seconds  = 20
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_event_dead_letter.arn
    maxReceiveCount     = 2
  })
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

resource "aws_sqs_queue" "payment_event_dead_letter" {
  name              = "${var.environment}-payment-event-dead-letter"
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

resource "aws_sqs_queue" "payout_reconcile" {
  name                       = "${var.environment}-payout-reconcile"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 259200
  receive_wait_time_seconds  = 20
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payout_reconcile_dead_letter.arn
    maxReceiveCount     = 2
  })
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

resource "aws_sqs_queue" "payout_reconcile_dead_letter" {
  name              = "${var.environment}-payout-reconcile-dead-letter"
  kms_master_key_id = data.aws_kms_key.sqs_sse_key.arn
}

data "aws_kms_key" "sqs_sse_key" {
  // Default SQS encryption key
  key_id = "alias/aws/sqs"
}
