FROM node:16.20.1-alpine3.17@sha256:77e07be8ecf734e337b1b7d8eaa44abcb87320decffc030ad073354e609aa951

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
