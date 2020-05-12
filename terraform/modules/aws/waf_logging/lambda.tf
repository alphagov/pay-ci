locals {
  lambda_function_name = "waf-kinesis-splunk-transformation"
}

data "archive_file" "zip_lambda" {
    type        = "zip"
    source_file = "${path.module}/../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.js"
    output_path = "${path.module}/../../../../lambda/waf-to-splunk-kinesis-data-transformation/index.zip"
}


resource "aws_lambda_function" "kinesis_data_transformation_lambda" {
  provider         = aws.us
  filename         = data.archive_file.zip_lambda.output_path
  function_name    = local.lambda_function_name
  role             = aws_iam_role.iam_kinesis_data_transformation_lambda.arn
  handler          = "index.handler"
  description      = "An Amazon Kinesis Firehose stream processor that accesses the records in the input and returns them with a processing status."
  source_code_hash = data.archive_file.zip_lambda.output_base64sha256
  runtime          = "nodejs12.x"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs, 
    aws_cloudwatch_log_group.waf_kinesis_data_transformation_log_group
  ]
}

resource "aws_cloudwatch_log_group" "waf_kinesis_data_transformation_log_group" {
  provider          = aws.us
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "iam_kinesis_data_transformation_lambda" {
  name = "${local.lambda_function_name}-role"
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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_kinesis_data_transformation_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
