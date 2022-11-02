# Pay Concourse Runner with java 17

This Docker image identical to the original [governmentdigitalservice/pay-concourse-runner](https://github.com/alphagov/pay-ci/tree/master/ci/docker/concourse-runner) but with Java 17. The requirement for Java 17 comes from the fact that [webhooks](https://github.com/alphagov/pay-webhooks) uses it.
