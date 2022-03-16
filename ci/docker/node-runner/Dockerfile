# See the container_image_versions.json file for the currently in-use versions
ARG SOURCE_CONTAINER_IMAGE_VERSION
FROM node:${SOURCE_CONTAINER_IMAGE_VERSION}

RUN npm install aws-sdk@^2.x.x
RUN npm install @octokit/rest@^18.x.x
