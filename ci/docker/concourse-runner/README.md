# Pay Concourse Runner

This Docker image is used as an environment to build and run
Pay application tests on Concourse CI.

Pay application tests require external Docker image dependencies,
this environment uses Docker-in-Docker to support this on
Concourse.

The container entrypoint configures a lightweight init script
(via Tini) to manage the running process. This ensures that
process signals are interpreted correctly and any running
Docker containers are correctly cleaned up before exiting.

## Loading external Docker images

If your test environment requires external docker image dependencies,
these can be loaded as task *inputs* using the Concourse `registry-image`
resource and using the `oci` image format. This will ensure the
Concourse resource cache is used between job runs.

See: https://github.com/concourse/registry-image-resource#behavior

Oci images may be loaded by the Docker daemon using `docker load`

# Example Pipeline:

```yml
resources:
  - name: postgres
    type: registry-image
    source:
      repository: postgres/11.1

jobs:
  - name: test
    plan:
      - get: docker-postgres
        resource: postgres
        params:
          format: oci
      - task:
        privileged: true
        config:
          platform: linux
          image_resource:
            type: registry-image
            source:
              repository: govukpay/concourse-runner
            inputs:
              - name: docker-postgres
          run:
            path: bash
            args:
              - -ec
              - |
                ls -la
                
                source /docker-lib.sh
                start_docker

                echo "Loading Docker images..."
                pids=
                index=0
                for image_dir in docker/*/; do
                  docker load -qi "${image_dir}image.tar" & pids[${index}]=$!
                  index="$(( "${index}" + 1 ))"
                done
                for pid in ${pids[*]}; do
                  wait "$pid"
                done

                # run your task requiring docker or docker-compose here
                docker images
```

## Further information

For more information see the following resources:
 - https://github.com/meAmidos/dcind
 - https://github.com/krallin/tini
