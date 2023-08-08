FROM node:16.20.1-alpine3.17@sha256:d68deb2974609e4a2d65046c8de72ad2095be2cffc9bf67f22acf38eeb6c7bb5

# As of node 15 the docker container fails to npm install without either a WORKDIR or -g
WORKDIR /node-runner

RUN npm install -g aws-sdk@^2.x.x
RUN npm install -g @octokit/rest@^18.x.x

ENV NODE_PATH=/usr/local/lib/node_modules
