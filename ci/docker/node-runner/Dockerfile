FROM node:16.18.1-alpine3.15@sha256:064ec802eeed651485f00773656cdfebe2c830def4a924d404b9da66be630090

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
