locals {
  transformation_lambda_function_name = "cloudfront-log-kinesis-splunk-transformation"
}

data "archive_file" "zip_transformation_lambda" {
    type        = "zip"
    source_file = "${path.module}/../../../../lambda/${local.transformation_lambda_function_name}/index.js"
    output_path = "${path.module}/../../../../lambda/${local.transformation_lambda_function_name}/index.zip"
}

resource "aws_lambda_function" "kinesis_data_transformation_lambda" {
  filename         = data.archive_file.zip_transformation_lambda.output_path
  function_name    = local.transformation_lambda_function_name
  role             = aws_iam_role.iam_kinesis_data_transformation_lambda.arn
  handler          = "index.handler"
  description      = "An Amazon Kinesis Firehose stream processor to transform Cloudfront access logs into splunk HEC format."
  source_code_hash = data.archive_file.zip_transformation_lambda.output_base64sha256
  runtime          = "nodejs12.x"
  timeout          = 60

  depends_on = [
    aws_iam_role_policy_attachment.transfomation_lambda_logs, 
    aws_cloudwatch_log_group.cloudfront_log_kinesis_data_transformation_log_group
  ]
}

resource "aws_cloudwatch_log_group" "cloudfront_log_kinesis_data_transformation_log_group" {
  provider          = aws.us
  name              = "/aws/lambda/${local.transformation_lambda_function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "iam_kinesis_data_transformation_lambda" {
  name = "${local.transformation_lambda_function_name}-role"
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

resource "aws_iam_role_policy_attachment" "transfomation_lambda_logs" {
  role       = "${aws_iam_role.iam_kinesis_data_transformation_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
