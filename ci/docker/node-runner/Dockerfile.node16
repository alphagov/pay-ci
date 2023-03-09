FROM node:16.19.1-alpine3.17@sha256:2ca257ee86a65e8d7fe6bb0ed3df2e7336b7c5a1662512627c99428beed8bdae

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
