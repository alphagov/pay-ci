FROM node:16.20.2-alpine3.17@sha256:bbc110afcd56dea9d27969ce1c3585aac53192ad14b364b6c5cb1f25a144ad9f

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
