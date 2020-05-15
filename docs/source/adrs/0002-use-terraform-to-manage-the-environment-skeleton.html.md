---
title: 0002 Use terraform to manage the environment skeleton
hide_in_navigation: true
---

# ADR 2: Use terraform to manage the environment skeleton

Date: 2020-01-27

## Status

Accepted

## Context

Cloud Foundry allows you to configure applications in a declarative way using
"manifests". Manifests allow you to configure lots of things, including:

* memory and disk
* buildpacks
* environment variables
* bound services
* routes

However, there's currently no "cloudfoundry" way of declaratively configuring
service instances (such as which database plans and extensions to use) or
network policies.

It's also inconvenient to configure things which change for every environment
in the application's manifest file. For example, although we can specify the
route in the manifest file the application will need different routes in
different environments.

Usually things like services and network policies are managed in an ad hoc
way, either by developers running `cf create-service` / `cf add-network-policy`
manually, or with shell scripts in a pipeline. Compared to modern infrastructure
tools this approach has some drawbacks:

* changes to service instances are not version controlled (e.g. when a database plan changes)
* removing services or network policies usually needs to be done in an ad-hoc way
* scripts either need to be run once, or made idempotent (which adds to their complexity)

Terraform is an infrastructure as code tool which solves many of these problems. There's a
[cloudfoundry terraform provider](https://github.com/cloudfoundry-community/terraform-provider-cf)
which allows terraform to be used to manage cloudfoundry resources.

## Decision

We will use terraform to manage the bit of the environment which can't be
managed in manifests due to lack of support in cloudfoundry (services,
network policies), or that are unique to each environment (routes).

Application manifests should not specify the route that the application runs
on, because this is environment specific.

Application manifests should specify their service bindings, because this is not
environment specific.

Application manifests should specify anything that is specific to the application,
including memory, buildpacks, and environment variables.

To manage routes and network policies, terraform will have to create empty
applications (because network policies depend on applications). We will use
the `ignore_changes` terraform lifecyle option to prevent terraform from managing
these applications once they are created (this workaround could be avoided by adding
support for v3 applications to the terraform provider).

## Consequences

* we will have version controlled, declarative configuration for our environment
* addition / removal of services and network policies will be handled by terraform
* updates of services will be handled by terraform
* application manifests should not configure routes
* application manifests should configure their service bindings
* concourse will run terraform with the cloudfoundry provider
