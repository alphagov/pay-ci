FROM node:18.20.0-alpine3.18@sha256:63008551461d4550a3567af2d56ebb624e56db93f7ef951bf2ea5f41ef63d2e4

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
