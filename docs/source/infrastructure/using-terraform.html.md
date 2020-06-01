---
title: Using Terraform
---

# Using Terraform

Pay uses Terraform to manage all infrastructure residing in AWS staging & production environments.

All Terraform code is located in the `/terraform` directory in the [pay-omnibus repository](https://github.com/alphagov/pay-omnibus):

```sh
/terraform
  /staging-account # Manages staging AWS account configuration & users
  /modules # Shared Terraform modules used by staging & production
  /staging-aws # Manage staging AWS infrastructure
  /staging-paas # Manage staging PaaS infrastructure
```

## Getting started with Terraform

Install Terraform `v0.12.18` or later. You can use [tfenv](https://github.com/tfutils/tfenv) to do this.
 
## Terraform Plugins

Pay's Terraform uses the AWS and Pass plugins.

The Pass plugin is used to decrypt secrets located in the `/secrets` directory and must be manually installed.

1. Download the [Pass plugin binary](https://github.com/camptocamp/terraform-provider-pass/releases)
2. Move the downloaded binary into your Terraform plugins directory:

```sh
mv terraform-provider-pass ~/.terraform.d/plugins
```

## Run Terraform with AWS Credentials

Ensure you have access to the Pay AWS account by assuming a role delegated via the gds-users account.

Use [aws-vault](https://github.com/99designs/aws-vault) to manage credentials and execute commands using temporary credentials.

Initialise Terraform locally using the follwing commands:

```sh
cd /path/to/pay-omnibus/terraform/account
aws-vault exec <name-of-account> -- terraform init
cd /path/to/pay-omnibus/terraform/staging
aws-vault exec <name-of-account> -- terraform init
```
