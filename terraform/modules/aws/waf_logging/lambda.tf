data "archive_file" "zip_lambda" {
    type        = "zip"
    source_file = "../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.js"
    output_path = "../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.zip"
}


resource "aws_iam_role" "iam_kinesis_data_transformation_lambda" {
  name = "iam_kinesis_data_transformation_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "kinesis_data_transformation_lambda" {
  filename      = "../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.zip"
  function_name = "kinesis_data_transformation_lambda"
  role          = aws_iam_role.iam_kinesis_data_transformation_lambda.arn
  handler       = "exports.handler"
  provider      = aws.us

  source_code_hash = "${filebase64sha256("../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.zip")}"

  runtime = "nodejs12.x"
}