FROM node:16.20.0-alpine3.17@sha256:01b4c77bab0eec8c12c15ca96d1da583ee61d3bd710432d6fa5d0bf9132ae5e0

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
