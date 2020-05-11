data "archive_file" "zip_lambda" {
    type        = "zip"
    source_file = "${path.module}/../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.js"
    output_path = "${path.module}/../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.zip"
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
  provider         = aws.us
  filename         = data.archive_file.zip_lambda.output_path
  function_name    = "waf-kinesis-splunk-transformation"
  role             = aws_iam_role.iam_kinesis_data_transformation_lambda.arn
  handler          = "index.handler"
  description      = "An Amazon Kinesis Firehose stream processor that accesses the records in the input and returns them with a processing status."
  source_code_hash = data.archive_file.zip_lambda.output_base64sha256
  runtime          = "nodejs12.x"
}