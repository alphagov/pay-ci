FROM docker:19.03

RUN apk add --no-cache \
  bash \
  curl \
  # dockerd dependencies
  iptables \
  util-linux

RUN apk add --no-cache \
  openjdk11 \
  npm \
  maven \
  tini \
  docker-compose>1.25.4-r1 \
  git \
  curl \
  --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY ./docker-helpers.sh /
COPY ./docker-wrapper /usr/local/bin/

ENTRYPOINT [ "docker-wrapper" ]
CMD "ash"