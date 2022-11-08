FROM node:19.0.0-alpine3.15@sha256:51ef6d118988cf534ed8cfee99d098923d77707da74ab04cad5fb33e91558a18

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
