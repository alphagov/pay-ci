resource "aws_kinesis_firehose_delivery_stream" "cf_log_kinesis_stream" {
  name        = "cloudfront-logs-govuk-pay-kinesis-stream-${var.environment}"
  destination = "splunk"

  splunk_configuration {
    hec_endpoint               = var.splunk_hec_endpoint
    hec_token                  = var.splunk_hec_token
    hec_acknowledgment_timeout = 600
    hec_endpoint_type          = "Event"
    s3_backup_mode             = "FailedEventsOnly"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.cf_logs_kinesis_stream.name
      log_stream_name = "SplunkDelivery"
    }

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.kinesis_data_transformation_lambda.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = 3
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = 60
        }
        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.cf_logs_firehose_delivery.arn
        }
      }
    }
  }

  s3_configuration {
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
    role_arn           = aws_iam_role.cf_logs_firehose_delivery.arn
    bucket_arn         = aws_s3_bucket.cf_log_backup_bucket.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.cf_logs_kinesis_stream.name
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_cloudwatch_log_group" "cf_logs_kinesis_stream" {
  name              = "/aws/kinesisfirehose/cloudfront-logs-govuk-pay-kinesis-stream-${var.environment}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "splunk_delivery_stream" {
  name           = "SplunkDelivery"
  log_group_name = aws_cloudwatch_log_group.cf_logs_kinesis_stream.name
}

resource "aws_cloudwatch_log_stream" "s3_delivery_stream" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.cf_logs_kinesis_stream.name
}

// Used to store logs which have failed to be delivered to Splunk
resource "aws_s3_bucket" "cf_log_backup_bucket" {
  bucket = "govuk-pay-cloudfront-logs-delivery-backup-${var.environment}"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "cf_log_backup_bucket" {
  bucket = aws_s3_bucket.cf_log_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_iam_role" "cf_logs_firehose_delivery" {
  name               = "cloudfront-logs-firehose-delivery-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
EOF
}

resource "aws_iam_role_policy" "cf_logs_firehose_delivery" {
  name   = "cloudfront-logs-firehose-delivery-policy"
  role   = aws_iam_role.cf_logs_firehose_delivery.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.cf_log_backup_bucket.arn}",
                "${aws_s3_bucket.cf_log_backup_bucket.arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${aws_lambda_function.kinesis_data_transformation_lambda.arn}:$LATEST"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.cf_logs_kinesis_stream.arn}:*"
            ]
        }
    ]
}
EOF
}