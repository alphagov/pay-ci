FROM node:18.12.0-alpine3.15@sha256:cc01b1f106743660b64c19b5ed6668be7a6523f28229103af5e77c381f68babc

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
