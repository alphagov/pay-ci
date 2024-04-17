FROM node:18.20.2-alpine3.19@sha256:80338ff3fc4e989c1d5264a23223cec1c6014e812e584e825e78d1a98d893381

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
