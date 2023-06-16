FROM node:16.20.0-alpine3.17@sha256:fb4c5fcefe7cf706ab7f9eed97258641f33ca318b03f072119180133ab3ef334

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
