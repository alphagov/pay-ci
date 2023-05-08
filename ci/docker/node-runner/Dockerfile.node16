FROM node:16.20.0-alpine3.17@sha256:f1657204d3463bce763cefa5b25e48c28af6fe0cdb0f68b354f0f8225ef61be7

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
