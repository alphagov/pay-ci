sqs_config = {
  region                     = var.aws_region
  capture_queue_url          = "https://sqs.${var.aws_region}.amazonaws.com/${var.aws_account_id}/${var.environment}-capture"
  event_queue_url            = "https://sqs.${var.aws_region}.amazonaws.com/${var.aws_account_id}/${var.environment}-payment-event"
  payout_reconcile_queue_url = "https://sqs.${var.aws_region}.amazonaws.com/${var.aws_account_id}/${var.environment}-payout-reconcile"
}

resource "cloudfoundry_user_provided_service" "sqs-cde" {
  name  = "sqs"
  space = data.cloudfoundry_space.cde_space.id

  credentials = local.sqs_config
}

resource "cloudfoundry_user_provided_service" "sqs" {
  name  = "sqs"
  space = data.cloudfoundry_space.space.id

  credentials = local.sqs_config
}