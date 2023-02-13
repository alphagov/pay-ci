FROM node:16.19.0-alpine3.16@sha256:744978bbfd0326b77b2a54470a903dd0748f7084542bab76e15e4a3a9946d366

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
