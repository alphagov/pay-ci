---
hide_in_navigation: true
---

# ADR 3: Use a user provided service for service discovery

Date: 2020-01-28

## Status

Accepted

## Context

Most of Pay's microservices communicate with several other microservices.
This means each service needs to know the URLs of the other services it talks
to. These are currently managed through environment variables.

Because the URLs have to be different in every environment they can't be specified
on a per application basis (in the manifest). They currently have to be
passed in at deployment time. This leads to complexity in the deployment
system (in our case concourse), which has to know about application routes
and which applications need to talk to each other.

Cloudfoundry has a concept called "[user provided services](https://docs.cloudfoundry.org/devguide/services/user-provided.html#credentials)",
which allow you to create services which provide some configuration to any
application which binds to them. These are useful when multiple applications
need to share the same bit of configuration (for example, several applications
need to know the URL that card-connector is running on).

## Decision

We will use a user provided service to allow the apps to discover each other's URLs.

This will look something like this:

```shell
cf create-user-provided-service app-catalog -p '{
  "adminusers_url": "http://adminusers.example.com:8080",
  "cardid_url": "http://cardid.example.com:8080",
  ... etc ...
}'
```

Assuming we use terraform to manage application routes (see [ADR 0002](0002-use-terraform-to-manage-the-environment-skeleton)),
we can create the user provided service as part of the terraform, meaning
terraform should be the only system that needs to know about application
routes.

## Consequences

* applications will need to bind to a service to discover other applications URLs
* application manifests will not need to configure application URL environment variables
* we'll need to use some mechanism to read VCAP_SERVICES and provide application URLs to the applications
* terraform will be the only piece of infrastructure which knows how to configure application routes (assuming ADR-0002)
