FROM node:21.1.0-alpine3.18@sha256:df76a9449df49785f89d517764012e3396b063ba3e746e8d88f36e9f332b1864

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
