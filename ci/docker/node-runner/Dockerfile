FROM node:18.19.1-alpine3.18@sha256:bacc59da35fc5ddf4b93846733e0d5b9bfe49a118a0240e9d31578dd6a7417c0

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
