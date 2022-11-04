# Pay Node Runner

This Docker container is used to run [JS scripts](https://github.com/alphagov/pay-ci/tree/master/ci/scripts)
within tasks on Concourse CI.

Note there is only one Dockerfile in this repository for node16 for now, however the symbolic link 
has been kept in this folder (defaulting to Dockerfile.node16), to prepare for future node updates.

You can build the node16 version by providing the `--file` flag to docker build:

```
docker build -f Dockerfile.node16 -t governmentdigitalservice/pay-node-runner:node16-local .
```
