FROM node:16.20.0-alpine3.17@sha256:1cd89de178c5f0d886e56e7505420d5e6e53d353da302d6b3b61b22221bfde29

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
