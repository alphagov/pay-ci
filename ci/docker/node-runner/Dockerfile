FROM node:18.20.3-alpine3.19@sha256:acb08e6aa07aa2c24bd4b8bb8031b9032dfa7b4aefadf111b634d3e0b7b18f39

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
