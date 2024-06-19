FROM node:18.20.3-alpine3.19@sha256:e5df78451e4a2dc2e8605642b1d7691bf079d6fb66ae2d862714a88b4383ec61

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x
RUN npm install -g @aws-sdk/client-sts@^3.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
