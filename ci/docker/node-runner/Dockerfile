FROM node:18.19.1-alpine3.18@sha256:1163db1dad710d579fc19831492f50c8b04ce6221d4fa86f9c2f5d564d35daa1

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
