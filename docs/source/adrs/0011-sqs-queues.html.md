---
title: 0011 AWS SQS Queues in PaaS
hide_in_navigation: true
---

# ADR 11: AWS SQS Queue Configuration in PaaS

Date: 09-06-20

## Status

Accepted

## Context

Pay applications use AWS SQS (Simple Queue Service) for message queueing and asynchronous work. GOV.UK PaaS does not provide an SQS backing service for applications.

The GOV.UK Pay to GOV.UK PaaS migration already uses a “hybrid” architecture, leaving some infrastructure components within AWS as well as on GOV.UK PaaS.

### Application Configuration

Applications running on GOV.UK PaaS will require individual AWS credentials in their configuration since AWS role and instance permissions do not work on GOV.UK PaaS.

Application IAM user accounts will be provided with granular permissions, ensuring that they may only perform specific actions on a carefully controlled list of AWS resources.

Access policies will be configured so that while the SQS queue is publicly accessible, access to read/write/delete actions will be restricted via IAM policies to ensure that only connector and/or ledger will be able to access each queue in the manner expected.

Access to SQS KMS keys will also be provided allowing applications to use SQS server-side message encryption.

IAM accounts will be provisioned using the AWS Terraform provider.

### Queue Connectivity

It is not possible to use AWS VPC endpoints or Private Link within GOV.UK PaaS as this would affect other PaaS tenants. Therefore public SQS endpoints will be used. However, all connections will use TLS and server-side message encryption will be enabled.

In addition, IAM account authentication credentials for applications running in GOV.UK PaaS will have a policy allowing connectivity to AWS resources from GOV.UK PaaS egress IP addresses only.

### SQS Queue Configuration 

As we are replicating the already existing use case for SQS queues that we have within Pay, the values regarding retention policy and dead letter queue set up should match that of our already existing implementations. 

## Decision

We will provision SQS queues in our own AWS accounts and provide applications running on GOV.UK PaaS with credentials to access specific resources.

## Consequences

- GOV.UK Pay applications running on GOV.UK PaaS will be able to securely connect to SQS resources provisioned in GOV.UK Pay AWS accounts.
