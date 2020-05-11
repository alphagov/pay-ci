output "kinesis_stream_id" {
  value = aws_kinesis_firehose_delivery_stream.waf_kinesis_stream.id
}