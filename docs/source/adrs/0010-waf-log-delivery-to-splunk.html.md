---
hide_in_navigation: true
---

# ADR 10: AWS WAF Logging using Kinesis Firehose Splunk Delivery

Date: 13-05-20

## Status

Accepted

## Context

As part of the work to change our WAF from Nginx's NAXSI to Amazon WAF we need to deliver logs regarding violations to Splunk for auditablilty and compliance.

The reliability of log delivery is especially important since PCI requires retention of logs, and mandates the use of logs for several of its requirements.

A spike was conducted to review the feasibility of using [AWS Kinesis Firehose Splunk Delivery Stream](https://aws.amazon.com/kinesis/data-firehose/splunk/) to provide a managed integration with Splunk for log storage and analysis. This provides a maintenance free, reliable integration with Splunk HEC. In addition, Splunk provides an [AWS Add-on](https://docs.splunk.com/Documentation/AddOns/released/AWS/DataTypes) supporting log sourcetypes for various AWS log formats - including JSON produced by Kinesis Firehose. 

Kinesis Firehose Delivery stream supports data transformation, allowing the WAF log format to be annotated, or additional Splunk HEC Event properties to be appended before delivery.

Splunk [indexer acknowledgement](https://docs.splunk.com/Documentation/Splunk/8.0.3/Data/AboutHECIDXAck) is used to ensure reliable delivery of log data from Kinesis Firehose. Logs that fail to be delivered are retried and eventually backed up to S3.

![AWS WAF Log to Splunk Sequence Diagram](/images/adrs/0010-waf-log-sequence-diagram.svg)

## Decision

We will use the Kinesis Firehose Delivery Stream for Splunk to process and deliver logs from AWS WAF to the GDS Splunk instance.

## Consequences

 - WAF logs will be reliably delivered to Splunk.
 - A data transformation Lambda will need to be developed to transform WAF logs to Splunk HEC format.
 - The integration and delivery component between AWS and Splunk is fully managed and maintenance free.
