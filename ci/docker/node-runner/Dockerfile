FROM node:18.20.3-alpine3.19@sha256:eb460581aaed291f4ce5a32498509269e3bb1da2a482601a728c2ea2c14bd01f

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x
RUN npm install -g @aws-sdk/client-sts@^3.x.x
RUN npm install -g @aws-sdk/client-ecs@^3.x.x
RUN npm install -g @aws-sdk/client-synthetics@^3.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
