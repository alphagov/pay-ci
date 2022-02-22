FROM docker:20.10.10

RUN apk add --no-cache \
  aws-cli \
  bash \
  curl \
  docker-compose \
  netcat-openbsd \
  git \
  python3 \
  ca-certificates \
  jq \
  openjdk11 \
  npm \
  maven \
  tini \
  # dockerd dependencies
  iptables \
  util-linux

RUN apk add --virtual build-dependencies build-base

RUN curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v1.86.0/pact-1.86.0-linux-x86_64.tar.gz \
    && tar xzf pact-1.86.0-linux-x86_64.tar.gz \
    && rm -f pact-1.86.0-linux-x86_64.tar.gz

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
