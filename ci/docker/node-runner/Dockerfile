FROM node:18.20.6-alpine3.20@sha256:cee65f51bda64bcb9ba38a7cc35b4d8bfef8ada2d3a97653064906ee400465e6

ARG FLY_CLI_SHA256SUM=c126f1be24086aea0fa06fecbd4e50956b68aca2b1b920b6fc8e3d0cdbcfa2a2

RUN echo "$FLY_CLI_SHA256SUM  /tmp/fly" >> /tmp/fly.sha256 \
  && wget -O /tmp/fly 'https://pay-cd.deploy.payments.service.gov.uk/api/v1/cli?arch=amd64&platform=linux' \
  && sha256sum -c /tmp/fly.sha256 \
  && mv /tmp/fly /usr/local/bin/ \
  && chmod 555 /usr/local/bin/fly
# As of node 15 the docker container fails to npm install without either a WORKDIR or -g

WORKDIR /node-runner

RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x
RUN npm install -g @aws-sdk/client-sts@^3.x.x
RUN npm install -g @aws-sdk/client-ecs@^3.x.x
RUN npm install -g @aws-sdk/client-synthetics@^3.x.x
RUN npm install -g @aws-sdk/client-sns@^3.x.x
RUN npm install -g @aws-sdk/client-ssm@^3.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
