FROM node:16.20.1-alpine3.17@sha256:5513d8d0c2f69c2028bbecbedc679954686e3e9c0c3e79da26b931def18db034

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
