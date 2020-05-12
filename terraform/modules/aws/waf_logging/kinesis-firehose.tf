resource "aws_iam_role" "waf_firehose_iam_role" {
    name = "waf-firehose-iam-role"
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

resource "aws_iam_role_policy" "waf_firehose_s3_policy" {
    name   = "waf-firehose-s3-policy"
    role   = aws_iam_role.waf_firehose_iam_role.id
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
                "${aws_s3_bucket.waf_log_bucket.arn}",
                "${aws_s3_bucket.waf_log_bucket.arn}/*"
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
        }
    ]
}
EOF
}


resource "aws_kinesis_firehose_delivery_stream" "waf_kinesis_stream" {
  provider    = aws.us
  name        = "aws-waf-logs-govuk-pay-waf-kinesis-stream-${var.environment}"
  destination = "splunk"

  splunk_configuration {
    hec_endpoint               = var.splunk_hec_endpoint
    hec_token                  = var.splunk_hec_token
    hec_acknowledgment_timeout = 600
    hec_endpoint_type          = "Event"
    s3_backup_mode             = "FailedEventsOnly"

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
            parameter_value = aws_iam_role.iam_kinesis_data_transformation_lambda.arn
        }
      }
    }
  }

  s3_configuration {
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
    role_arn           = aws_iam_role.waf_firehose_iam_role.arn
    bucket_arn         = aws_s3_bucket.waf_log_bucket.arn
  }
}