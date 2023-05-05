FROM node:20.1.0-alpine3.17@sha256:6e56967f8a4032f084856bad4185088711d25b2c2c705af84f57a522c84d123b

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
