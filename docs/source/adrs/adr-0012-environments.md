---
title: 0012 Environments and continuous deployment
hide_in_navigation: true
---

# ADR 12: Environments and continuous deployment

Date: 3-08-20

## Status

Proposed

## Context

GOV.UK Pay currently has the following environments in AWS

| Env        | Purpose/Comments |  
| ------------- | ------------- |
| test-12 | manual product acceptance testing; continuously deployed from master builds |
| test-perf-1 | automated performance testing; scaled up daily for the duration of the perf test and scaled down again. Gets latest code each day|
| production-2 | production environment; zero-downtime deploys are automated but triggered manually by a developer |
| staging-2 | used to rehearse complex production deployments; as close as possible to production including application versions and infra code; zero-downtime deploys are automated but triggered manually by a developer|

We believe that all of these environments are still needed in after PaaS migration, so we would expect the following PaaS spaces to exist:

## Decision


## Consequences
