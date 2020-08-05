---
title: 0013 Test Environment 
hide_in_navigation: true
---

# ADR 13: Test Environment

Date: 05-08-20

## Status

Accepted

## Context

GOV.UK Pay deploys applications to three separate environments as part of the existing CI/CD pipeline. These are: test, staging and production.

The GOV.UK Pay migration team initially discussed the removal the test environment, however it was decided that it should be retained. The purpose of the test environment is summarised below:

### Purpose of the test environment

 - To safely & continuously deploy and test all merged application changes before promotion to staging & production
 - To provide all GOV.UK Pay with developers admin access to a fully functional environment without requiring fully trusted access to staging and production accounts
 - To provide an environment to test and debug application builds
 - To provide a production-like hosting environment promoting reuse of infrastructure configuration
 - To provide an environment to perform UAT

### Architecture

GOV.UK Pay running on GOV.UK PaaS involves a hybrid architecture, where some AWS services continue to be managed by GOV.UK Pay.

The test environment will continue to use a hybrid architecture, providing a much smaller but production-like environment.

Separate GOV.UK PaaS and AWS sub accounts will be created for the purpose of hosting the test environment. This will enable testing of infrastructure configuration changes such as AWS WAF firewall or CloudFront CDN configuration and any side effects of such changes on applications running on GOV.UK PaaS before they are applied to staging and production environments.

### VPC Peering

A VPC peering connection will be created between the test AWS account and GOV.UK PaaS AWS environments. This will allow connectivity to private RDS instances in the test account from GOV.UK PaaS.

To ensure the peered subnet ranges in the test AWS account do not collide with exising peered networks in GOV.UK PaaS, an appropriate VPC CIDR range will be selected. Different ranges will need to be selected for staging and production AWS accounts.

See the [AWS VPC Peering documentation](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) for more information.

## Decision

We will create a test environment to host GOV.UK Pay applications before deployment to staging and production environments.

## Consequences

- All GOV.UK Pay team members will be provided access to a production-like environment
- Separate GOV.UK PaaS and AWS accounts will be created 
