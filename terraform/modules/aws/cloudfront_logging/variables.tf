variable "environment" {
  type        = string
  description = "Environment name (for example: staging)"
}

variable "log_bucket_id" {
  type        = string
  description = "Id of the CloudFront log destination bucket"
}

variable "log_bucket_arn" {
  type        = string
  description = "ARN of the CloudFront log destination bucket"
}