FROM node:18.20.1-alpine3.19@sha256:cbd31807a8b4621a9dea342a03f14e8c53f5ca78a395f426bb5bd0e7f071c47c

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
