# Pay Node Runner

This Docker container is used to run [JS scripts](https://github.com/alphagov/pay-ci/tree/master/ci/scripts)
within tasks on Concourse CI.

## Building

To build this image you will need to provide a build argument to choose which source image version you want.

For the currently in use versions see the `container_image_versions.json` file.

```
NODE12_AMD64_VERSION=$(jq '.node12.amd64' < source_container_image_verisons.json)
docker build --build-arg "SOURCE_CONTAINER_IMAGE_VERSION=$NODE12_AMD64_VERSION" govukpay/node-runner:local .
```

As part of the deployment pipeline both node12 and node16 versions will be produced, the source container versions will
be read from the `source_container_image_versions.json` file.
