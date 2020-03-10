---
hide_in_navigation: true
---

# ADR 7: Use Concourse to run E2E tests

Date: 2020-03-10

## Status

Accepted

## Context

In moving Pay's CI pipeline away from Jenkins, we need to find a new home for our endtoend tests.
Pays end to end tests are currently run on a very big Jenkins box, using docker compose to orchestrate the platform under test.
This means they require a large amount of compute - the box they currently run on
is huge, and we are still limited to only being able to run 3 e2e jobs at a time.

As part of the migration, Pay has built a build and deploy pipeline on the GDS shared Concourse. 
We also attempted to put the simpler parts of our testing piepline on Concourse
but found that to be quite complicated, so switched to using Travis to run our unit tests.
This means at the moment the whole pipeline is split across Travis and Concourse.

Pay obviously needs tests to run in a timely and reliable way. Currently on 
Jenkins the longest running e2e test suite takes around 4 minutes
and reliability is around 90%. Any replacement should improve on these figures.


We carried out some spikes into different ways we could run the e2e tests:
1. Using Travis <https://payments-platform.atlassian.net/browse/PP-6042>
1. Using Concourse to run the tests against a target deployed on the PaaS <https://payments-platform.atlassian.net/browse/PP-6206>
1. Using Concourse to run the tests against a target deployed on docker-compose
1. Using Buildkite <https://payments-platform.atlassian.net/browse/PP-6214>

For detailed discussion of the outcomes of the spikes see the relevant tickets.

The conclusion from these spikes was that options 3 and 4 were both viable. 
Option 3 is the most inline with GDS tech direction, but requires a bit more work to get the required performance - it is
possible to run many builds in parralel on separate worker boxes, but this comes less natively than in option 4.
Otion 4 is a good technological fit, but requires more work to get everything set up well, and is a distinct divergence from
current GDS technology.

## Decision
We will run the e2e tests in docker compose (as they currently are), on Concourse (option 3 above).
We will also move the rest of Pay's tests on to Concourse.
We will arrange for a sufficient number of concourse workers to be proviioned for Pay to ensure we are not blocked by e2e tests.
## Consequences

- We will have to move the unit/integration tests currently on travis to concourse
- We will have to continue to maintain up to date docker images for all our microservices
- Pay will only use concourse for all its CI/CD
