FROM node:18.20.1-alpine3.19@sha256:fdaafba89e47a9716571df803d7759392b51ba7fbaddbeefdb433abbaedc25f6

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
