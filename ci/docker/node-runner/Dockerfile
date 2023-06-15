FROM node:16.20.0-alpine3.17@sha256:bb21061bc553f3f44e073f8222f98d2186660c345d429cf6297ecc110ce80c5d

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
