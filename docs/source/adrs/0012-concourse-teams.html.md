---
title: 0012 Concourse Teams for CI and Deploy 
hide_in_navigation: true
---

# ADR 12: Concourse Teams for CI and Deploy

Date: 03-08-20

## Status

Accepted

## Context

Currently GOV.UK Pay has one team for both the CI and Deploy portions or our Concourse CI environment, this is problematic as too many concerns are grouped within one team and GDS best practice is to separate these concerns where possible. Our current model in Jenkins is a multi environment solution for both CI and Deploy and it makes sense for the new architecture to match that. This will allow us to greatly simplify our Concourse environment which currently is quite cluttered because it is required to do so much within a single team.

Our proposal is to move the CI pipelines and related infrastructure to a new team, ```pay-dev``` and keep the current deploy components and pipelines within the ```pay-deploy``` team.

### Structure

The CI pipelines will build the apps as PRs are created on Github and report the status of these builds. Then, upon merges to master, it will take the updates and place them within the PaaS test environment. If successful, it will also trigger a new release on Github tagged as test.

The deploy pipeline will check for releases with the test tag and when a release is created the deploy pipeline will then take the release and deploy it to the new staging environment, then if this is successful, will tag the release as staging, finally the deploy pipeline will deploy the new staging release to production.

## Decision

We will split the CI environment into two teams on Concourse, one for CI which will run tests and run the result in the test environment. The other, Deploy, will take releases and deplpoy it to staging and production.

## Consequences

- The deploy components for deploying to the new staging & production environments will exist within the current ```pay-deploy``` team
- The existing CI components will be placed within a new team on Concourse named ```pay-dev```
