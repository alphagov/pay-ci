---
title: Metrics
---

# AWS Metrics

AWS CloudWatch metrics are produced by all infrastructure components residing in AWS.

Hosted Graphite is used to aggregate metrics from all AWS accounts and GOV.UK PaaS infrastructure.

## Integration with AWS

Hosted Graphite provides a managed add-on supporting integration with AWS to access CloudWatch metric data.

Metrics are pulled from one or more configured AWS accounts into Hosted Graphite at regular intervals.

See the [Hosted Graphite AWS documentation](https://www.hostedgraphite.com/docs/integrationguide/ig_aws_cloudwatch.html) for more information: 

### Hosted Graphite Configuration

Hosted Graphite allows configuration of metric data for each AWS service and region within a given AWS account. This ensures only relevant metrics
are ingested. Metrics can be enabled for other services as required.

#### The following services are configured:

 - Cloudfront
 - Kinesis Streams
 - Kinesis Firehose
 - SQS
 - S3
 - Lambda Functions
 - Route 53

#### The following regions are configured:

 - US East 1 (For "global" services)
 - EU West 1
 - EU West 2

### AWS Account Credentials

Each AWS account is provisioned with a unique Hosted Graphite IAM user belonging to a "Services" group. This user
has minimal read-only permissions for CloudWatch metric and metric statistic data.

See the [Terraform IAM user defintion](https://github.com/alphagov/pay-omnibus/blob/develop/terraform/modules/aws/hosted-graphite.tf) for IAM permissons.
