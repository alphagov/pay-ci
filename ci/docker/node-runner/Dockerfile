FROM node:18.18.2-alpine3.18@sha256:3428c2de886bf4378657da6fe86e105573a609c94df1f7d6a70e57d2b51de21f

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
