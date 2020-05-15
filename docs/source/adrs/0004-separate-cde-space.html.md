---
title: 0004 Separate CDE space
hide_in_navigation: true
---

# ADR 4: Separate CDE space

Date: 2020-01-28

## Status

Accepted

## Context

[PCI DSS][pci] requires that the infrastructure used to host applications that
deal with cardholder data (card numbers, CVCs) is isolated from infrastructure
that doesn't process cardholder data.

There are also additional requirements such as controlling egress from CDE
infrastructure to the internet.

Pay currently has the following CDE applications:

- [pay-frontend](https://github.com/alphagov/pay-frontend)
- [pay-connector](https://github.com/alphagov/pay-connector)
- [pay-cardid](https://github.com/alphagov/pay-cardid)

On PaaS, Cloud Foundry decides the virtual machines (VMs) applications are
allocated to, creating the possibility that a CDE application runs on the same
VM as a non-CDE application. There are a few methods for achieving the
isolation requirements for CDE applications:

- [isolation segments](https://docs.cloudfoundry.org/adminguide/isolation-segment-index.html)
- [application security groups](https://docs.cloudfoundry.org/concepts/asg.html)

## Decision

Although we haven't yet decided on how we will implement VM isolation and
egress controls in PaaS, most of the options involve controls being applied at
the space level.

Therefore, we will create two PaaS spaces for every Pay environment: a CDE and
non-CDE space. The CDE apps will be deployed to the CDE space. Any services
used solely by the CDE apps (for example, the connector database) will also be
provisioned in the CDE space.

## Consequences

- The procedure for setting up a new Pay environment on PaaS will need to create
  an additional CDE space.
- Network policies from apps in the non-CDE space to the CDE space are still
  possible.
- A separate space gives us the option to limit developer access to the
  (non-)CDE spaces differently.

[pci]: https://en.wikipedia.org/wiki/Payment_Card_Industry_Data_Security_Standard
