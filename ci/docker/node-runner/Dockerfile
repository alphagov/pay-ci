FROM node:18.19.1-alpine3.18@sha256:3b50a0a2324cbaa28d57dad57019f8656b784a67743c58194718389cd29c18fe

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
