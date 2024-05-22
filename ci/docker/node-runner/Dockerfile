FROM node:18.20.3-alpine3.19@sha256:3120b21ed49333280d78dfe44b6eabc25c3309c3366bbcfa409b804334fd16ab

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
