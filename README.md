# pay-ci

- `ci`: Concourse pipelines and tasks
- `secrets`: Secrets store using [pass](https://passwordstore.org)

## Validating pipelines

There is a ['meta' task in the pr-ci pipeline](https://github.com/alphagov/pay-ci/blob/master/ci/pipelines/pr.yml#L2054) that checks PRs on this repo.

This check uses [pipecleaner](https://github.com/alphagov/paas-cf/tree/main/tools/pipecleaner#features), a tool maintained
by the PaaS team. You can run this manually against yaml files:

```
pipecleaner concourse/pipelines/*.yml concourse/tasks/*.yml
```
