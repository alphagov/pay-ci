resource "aws_iam_group" "services" {
  name = "Services"
}

resource "aws_iam_group" "applications" {
  name = "Applications"
}
