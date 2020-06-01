resource "aws_iam_user" "hosted_graphite" {
  name          = "hosted.graphite"
  force_destroy = true
}

resource "aws_iam_group_membership" "services_membership" {
  name = "services-group-membership"

  users = [
    "${aws_iam_user.hosted_graphite.name}",
  ]

  group = aws_iam_group.services.name
}

resource "aws_iam_policy" "hosted_graphite_policy" {
  name = "HostedGraphitePolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "cloudwatch:ListMetrics",
              "cloudwatch:GetMetricStatistics",
              "kinesis:ListStreams",
              "sqs:ListQueues",
              "cloudfront:ListDistributions"
          ],
          "Resource": [ "*" ]
      }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "hosted_graphite" {
  name       = "HostedGraphite"
  users      = ["${aws_iam_user.hosted_graphite.name}"]
  policy_arn = "${aws_iam_policy.hosted_graphite_policy.arn}"
}
