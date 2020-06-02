resource "aws_iam_user" "card_connector" {
  name = "card.connector"
  force_destroy = true
} 

resource "aws_iam_group_membership" "card_connector_applications_group_membership" {
  name = "applications_group_membership"

  users = [
    "${aws_iam_user.card_connector.name}",
  ]

  group = aws_iam_group.applications.name
}

resource "aws_iam_policy" "card_connector_queue_policy" {
  name = "card_connector_queue_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "",
          "Effect": "Allow",
          "Action": [
              "sqs:DeleteMessage",
              "sqs:ChangeMessageVisibility",
              "sqs:DeleteMessageBatch",
              "sqs:SendMessageBatch",
              "sqs:ReceiveMessage",
              "sqs:SendMessage",
              "sqs:ChangeMessageVisibilityBatch",
              "sqs:GetQueueUrl",
              "sqs:GetQueueAttributes"
          ],
          "Resource": [
            "${aws_sqs_queue.payout_reconcile.arn}",
            "${aws_sqs_queue.payment_event.arn}"
          ]
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "kms:GenerateDataKey",
            "kms:Decrypt"
        ],
        "Resource": "${data.aws_kms_key.sqs_sse_key.arn}"
      }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "card_connector_queue_policy_attachment" {
  user       = aws_iam_user.card_connector.name
  policy_arn = aws_iam_policy.card_connector_queue_policy.arn
}