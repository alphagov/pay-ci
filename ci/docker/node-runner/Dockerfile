FROM node:16.19.1-alpine3.17@sha256:0fcf4fb718a763fa53ac8d60073a7cd7dc1520076e08ea0180591174122e52f3

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
