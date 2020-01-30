---
hide_in_navigation: true
---

# ADR 5: Inline cardid-data into cardid before pushing to GOV.UK PaaS

Date: 2020-01-30

## Status

Accepted

## Context

The [pay-cardid](https://github.com/alphagov/pay-cardid) microservice is
responsible for retrieving card information for a given card number.

To do this, it requires a number of proprietary .csv files, which are provided
by various payment service providers. This data is sensitive in the sense
that it's encumbered by licence restrictions, so we need to take appropriate care
not to make it public.

The data is roughly 36 MB uncompressed, and changes rarely (a few times a year).

In the current infrastructure, cardid includes the sensitive cardid-data in a git
submodule which refers to a private repository on GitHub. This is built into the
pay-cardid docker image, which is then pushed to a private container registry.

We would like to deploy cardid to GOV.UK PaaS using the java buildpack. For
consistency with the other open source applications, we would like the build
artefact (a .jar file) to be in a public GitHub release. This means we cannot
include the sensitive data in the build artefact.

## Decision

When concourse deploys cardid to GOV.UK PaaS it will:

* download the cardid build artefact from github releases
* clone the pay-cardid repository recursively (which will include the private pay-cardid-data)
* insert the data from pay-cardid-data into the cardid build artefact
* push the modified cardid build artefact to GOV.UK PaaS

## Consequences

We will not have to make any code changes to cardid.

We will not have to set up any additional infrastructure (s3 buckets, secret
stores etc.) to support cardid.

The build artefact in GitHub releases will not be a full representation of
the deployed artefact.

It will be more difficult to `cf push` a working version of cardid locally
(for example to a dev environment), because locally built .jar files will not
contain the cardid-data.

The deployed package and droplet in GOV.UK PaaS will contain the pay-cardid-data.
The package and droplet are created as part of
[the cloudfoundry application staging process](https://docs.cloudfoundry.org/concepts/how-applications-are-staged.html),
and stored in a private S3 bucket owned by GOV.UK PaaS. Only people with
SpaceDeveloper access to the cloudfoundry space where the app is running and
GOV.UK PaaS administrators can access packages and droplets.

We will need to take care to ensure that the we use the commit of the
pay-cardid-data submodule that matches the version in the pay-cardid GitHub
release.
