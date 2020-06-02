resource "aws_iam_group" "services" {
  name = "Services"
}

resource "aws_iam_group" "applications" {
  name = "Applications"
}

resource "aws_iam_group_membership" "applications_group_membership" {
  name  = "applications_group_membership"

  users = [
    aws_iam_user.ledger.name,
    aws_iam_user.card_connector.name
  ]

  group = aws_iam_group.applications.name
}