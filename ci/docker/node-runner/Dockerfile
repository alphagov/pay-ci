FROM node:18.20.5-alpine3.20@sha256:162b79fedde05ef5d1dc1509561fcc9a21afb88585b9fed85b28d899b3f87637

ARG FLY_CLI_SHA256SUM=90a05559d36f259903ca76988b51fbca8948f0c30a42e260d27dda659052db22

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
