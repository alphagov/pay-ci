FROM docker:19.03

RUN apk add --no-cache \
  bash \
  curl \
  netcat-openbsd \
  git \
  python3 \
  ca-certificates \
  jq \
  # dockerd dependencies
  iptables \
  util-linux 

RUN apk add --no-cache \
  openjdk11 \
  npm \
  maven \
  tini \
  docker-compose>1.25.4-r1 \
  --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk
RUN apk add glibc-2.31-r0.apk

RUN apk add --virtual build-dependencies build-base

RUN curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v1.86.0/pact-1.86.0-linux-x86_64.tar.gz
RUN tar xzf pact-1.86.0-linux-x86_64.tar.gz
RUN rm -rf pact-1.86.0-linux-x86_64.tar.gz

RUN ln -s /pact/bin/pact /usr/local/bin \
    && ln -s /pact/bin/pact-broker /usr/local/bin \
    && ln -s /pact/bin/pact-message /usr/local/bin \
    && ln -s /pact/bin/pact-mock-service /usr/local/bin \
    && ln -s /pact/bin/pact-provider-verifier /usr/local/bin \
    && ln -s /pact/bin/pact-publish /usr/local/bin \
    && ln -s /pact/bin/pact-stub-service /usr/local/bin

COPY ./docker-helpers.sh /
COPY ./docker-wrapper /usr/local/bin/
ENTRYPOINT [ "docker-wrapper" ]

CMD "ash"
