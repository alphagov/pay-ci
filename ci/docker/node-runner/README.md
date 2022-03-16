# Pay Node Runner

This Docker container is used to run [JS scripts](https://github.com/alphagov/pay-ci/tree/master/ci/scripts)
within tasks on Concourse CI.

Note there are 2 Dockerfiles in this repository for now, one is for node12 and one for node16. The symbolic link of
Dockerfile to Dockerfile.node12 ensures node12 is still the default.

You can build the node16 version by providing the `--file` flag to docker build:

```
docker build -f Dockerfile.node16 -t govukpay/node-runner:node16-local .
```
