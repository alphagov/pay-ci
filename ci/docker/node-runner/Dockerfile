FROM node:16.20.1-alpine3.17@sha256:090f3ad0966dcdf8431bdfa85b26db8012836506979e25d856c00d3deaf84b27

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
