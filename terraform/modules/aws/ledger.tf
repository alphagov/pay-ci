resource "aws_iam_user" "ledger" {
  name = "ledger"
}

resource "aws_iam_user_group_membership" "ledger_group_membership" {
  user   = aws_iam_user.ledger.name
  groups = [aws_iam_group.applications.name]
}

resource "aws_iam_policy" "ledger_queue_policy" {
  name = "ledger_queue_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "sqs:ReceiveMessage",
            "sqs:GetQueueAttributes"
        ],
        "Resource": [
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

resource "aws_iam_user_policy_attachment" "ledger_queue_policy_attachment" {
  user       = aws_iam_user.ledger.name
  policy_arn = aws_iam_policy.ledger_queue_policy.arn
}