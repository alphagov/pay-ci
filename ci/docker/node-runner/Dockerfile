FROM node:18.20.4-alpine3.19@sha256:dfc737c864950bb3a56546b99ba2d2479d693d6563460a379fb56fe7ccfe6967

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws4@^1.x.x
RUN npm install -g @octokit/rest@^18.x.x
RUN npm install -g @aws-sdk/client-sts@^3.x.x
RUN npm install -g @aws-sdk/client-ecs@^3.x.x
RUN npm install -g @aws-sdk/client-synthetics@^3.x.x
RUN npm install -g @aws-sdk/client-sns@^3.x.x
RUN npm install -g @aws-sdk/client-ssm@^3.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
