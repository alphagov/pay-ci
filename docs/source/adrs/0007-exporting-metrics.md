# ADR 7: Exporting metrics

Date: 2021-04-20

## Status

Accepted

## Context
Once on the PaaS Pay still needs to retain, monitor and view application and system level metrics without loss of any current functionality offered on its current infrastructure.

Currently application metrics are pushed to an instance of carbon-relay which performs some filtering of metrics and prepending of the Hosted Graphite API token, which then relays them to Hosted Graphite via a stunnel process to wrap the connection in TLS. System level metrics are collected via AWS cloudwatch and relayed to Hosted Graphite. There are various dashboards and monitoring alerts set-up on Hosted Graphite which must be retained post migration.

Some PaaS tenants are using Prometheus for metric collection and this should be explored to honour our objective of using common PaaS tools first.

### Application Metrics
Pay spiked sending application metrics to Prometheus. To use the Reliability Engineering "Observe" Prometheus Service it would be necessary to add public routes to our apps to provide access for the PaaS service. This was thought unfavourable especially for applications running within the CDE space and may introduce PCI complexities to a shared service. Another option explored was running a Pay Prometheus application in Pay's space however this would add extra critical infrastructure for Pay to maintain which seems undesirable. For these reasons using Prometheus was discounted in favour of continued use of Hosted Graphite, which also negates the need to reproduce our dashboards and alerts. Application metrics can be sent to Hosted Graphite via our own instance of carbon-relay (with a stunnel side-car) running in our PaaS space.

### System Level Metrics
Pay spiked using the [PaaS metric-exporter](https://github.com/alphagov/paas-metric-exporter "Github") to export system metrics in StatsD format which met our requirements.

## Decision
Continue to use Hosted Graphite to store, view and alert on application and system level metrics. Continue to use carbon-relay and stunnel to send application level metrics whilst using the PaaS metric-exporter for system metrics.

## Consequences
- Maintain existing application and system metric functionality on current Hosted Graphite platform.
- Use PaaS standard tooling for sending system metrics.
- Using Hosted Graphite means we're not using the PaaS favoured Prometheus platform.
- Minimises work to rebuild dashboards and alerts.
