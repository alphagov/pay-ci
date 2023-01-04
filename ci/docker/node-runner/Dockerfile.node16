FROM node:16.19.0-alpine3.16@sha256:e023c53915c5e20df594809477dc249dd595a8e731a6e214c4dbdcf7431bf942

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
