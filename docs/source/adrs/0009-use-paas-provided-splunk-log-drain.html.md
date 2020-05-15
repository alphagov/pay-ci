---
hide_in_navigation: true
---

# ADR 9: User PaaS provided Splunk log drain 

Date: 2020-04-20

## Status

Accepted

## Context
Once on the PaaS Pay still needs its application logs to go to Splunk for auditability, debugging and alerting purposes. The reliability of this logging pipeline is critical since PCI requires retention of logs, and mandates the use of logs for several of its requirements. 
The cloudfoundry logging agent emits logs in syslog format, either over syslog protocol or over http <https://docs.cloudfoundry.org/devguide/services/log-management.html>. Our Splunk instance only accepts logs in Splunks very own HEC format (which is a particular format over http <https://dev.splunk.com/enterprise/docs/dataapps/httpeventcollector/>). So to drain logs from PaaS to splunk we need something that can convert from syslog to HEC. 
Pay spiked our own log converter which we ran on the PaaS. This did function correctly, but we had reservations about whether we could achieve the necessary level of resilience and reliability with this pattern. In particular it would not have been resilient to an outage from Splunk without significant further engineering effort.
GDS Techops have built a converter that achieves the same functionality, and is connected to a AWS Kinesis stream ensure resilience. This converter can be used easily from PaaS simply by specifying it as a log drain.
There appear to be some outstanding issues with how logs are segmented in to apps on the Splunk side.

## Decision
We will use the Techops Splunk log drain to ship our application logs to Splunk. We will work with Cyber and Techops to resolve outstanding issues with log classification in Splunk.

## Consequences
- Our application logs will be reliably shipped to Splunk
- A segment of our logging pipeline will be opaque to Pay developers, which may cause difficulties with diagnosis and debugging if there is a problem with our logs
- Making changes to our logging pipeline will likely be more difficult/bureaucratic