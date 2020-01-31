---
hide_in_navigation: true
---

# ADR 6: serve cardid data from an internal http static file server

Date: 2020-01-31

## Status

Accepted

Supercedes [ADR 5: inline cardid data into cardid](0005-inline-cardid-data-into-cardid-before-pushing-to-gov-uk-paas.html)

## Context

As described in [ADR 5](0005-inline-cardid-data-into-cardid-before-pushing-to-gov-uk-paas.html),
to run the cardid service, it needs to be able to access some private data
from the pay-cardid-data repository.

We can't put the data inside the build artefact, becuase the build
artefacts will be hosted publicly (in a GitHub release).

## Decision

Instead of inserting the data into the deployed artefact, we will load the
data from a URL on startup (implemented in this PR https://github.com/alphagov/pay-cardid/pull/211).

To ensure that the data remains private we will use an internal route which
is only exposed to the cardid microservice, for example `pay-cardid-data.apps.internal`.

We will use the existing `*_DATA_LOCATION` environment variables to configure
cardid to load its data from URLs like `http://pay-cardid-data.apps.internal/data/something.csv`.

We will use a staticfile buildpack to push the source code for cardid-data to
GOV.UK PaaS. We will not use a build artefact to avoid having to set up
infrastructure for hosting private build artefacts.

## Consequences

* It will be possible to `cf push` cardid (for example to a dev environment) without needing to include cardid-data in the JAR file
* cardid will fail to start if cardid-data is not deployed, or if the networking isn't set up properly
* we will need to take care when starting apps for the first time in a new environment that cardid-data is started before cardid
* we will have to run one more microservice (albeit a very small one)
* we will be able to deploy cardid-data independently of cardid, but it will not have any effect until cardid is restarted
