FROM docker:25.0.3-dind

ARG FLY_CLI_SHA256SUM=c6b93200a556227749b44705057598b81c73565c2fe52da1760679cdee0cdd96

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
  openjdk17 \
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

RUN echo "$FLY_CLI_SHA256SUM  /tmp/fly" >> /tmp/fly.sha256 \
  && wget -O /tmp/fly 'https://pay-cd.deploy.payments.service.gov.uk/api/v1/cli?arch=amd64&platform=linux' \
  && sha256sum -c /tmp/fly.sha256 \
  && mv /tmp/fly /usr/local/bin/ \
  && chmod 555 /usr/local/bin/fly

COPY ./docker-helpers.sh /
COPY ./docker-wrapper /usr/local/bin/
ENTRYPOINT [ "docker-wrapper" ]

CMD "ash"
