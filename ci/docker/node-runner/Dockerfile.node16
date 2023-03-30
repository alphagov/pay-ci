FROM node:16.20.0-alpine3.17@sha256:62f4ab95153aa57fb4fe3ce94e45545405b3c572cc76c582c7788ee0d486f8fd

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
