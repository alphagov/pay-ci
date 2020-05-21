locals {
  event_lambda_function_name = "cloudfront-log-event-process"
}

data "archive_file" "zip_log_event_lambda" {
  type        = "zip"
  source_file = "${path.module}/../../../../lambda/${local.event_lambda_function_name}/index.js"
  output_path = "${path.module}/../../../../lambda/${local.event_lambda_function_name}/index.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudfront_log_event_process.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.log_bucket_arn
}

resource "aws_lambda_function" "cloudfront_log_event_process" {
  filename         = data.archive_file.zip_log_event_lambda.output_path
  function_name    = local.event_lambda_function_name
  role             = aws_iam_role.iam_cloudfront_log_event_process_lambda.arn
  handler          = "index.handler"
  description      = "Processes access log files created by CloudFront in an S3 bucket and pushes log lines to a Kinesis Delivery Stream"
  source_code_hash = data.archive_file.zip_log_event_lambda.output_base64sha256
  runtime          = "nodejs12.x"
  timeout          = 60

  environment {
    variables = {
      DELIVERY_STREAM = ""
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudfront_log_lambda_logs, 
    aws_cloudwatch_log_group.cloudfront_log_event_process
  ]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.log_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cloudfront_log_event_process.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".gz"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_cloudwatch_log_group" "cloudfront_log_event_process" {
  name              = "/aws/lambda/${local.event_lambda_function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "iam_cloudfront_log_event_process_lambda" {
  name = "${local.event_lambda_function_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Allows the lambda to write its own logs to CloudWatch logs
resource "aws_iam_role_policy_attachment" "cloudfront_log_lambda_logs" {
  role       = aws_iam_role.iam_cloudfront_log_event_process_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//@todo add policy allowing put/batch put to Kinesis Firehose
