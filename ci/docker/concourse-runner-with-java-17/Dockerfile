FROM docker:25.0.4-dind

ARG FLY_CLI_SHA256SUM=90a05559d36f259903ca76988b51fbca8948f0c30a42e260d27dda659052db22
ARG PKL_VERSION=0.25.2
ARG PKL_CLI_SHA256SUM=33aa2b56b4852e00fce821073fa74c5302433e61f3cf8d07f44acd34b4cb13c9

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

RUN echo "$PKL_CLI_SHA256SUM  /tmp/pkl" >> /tmp/pkl.sha256 \
  && wget -O /tmp/pkl "https://github.com/apple/pkl/releases/download/${PKL_VERSION}/pkl-alpine-linux-amd64" \
  && sha256sum -c /tmp/pkl.sha256 \
  && mv /tmp/pkl /usr/local/bin \
  && chmod 555 /usr/local/bin/pkl

RUN echo "$FLY_CLI_SHA256SUM  /tmp/fly" >> /tmp/fly.sha256 \
  && wget -O /tmp/fly 'https://pay-cd.deploy.payments.service.gov.uk/api/v1/cli?arch=amd64&platform=linux' \
  && sha256sum -c /tmp/fly.sha256 \
  && mv /tmp/fly /usr/local/bin/ \
  && chmod 555 /usr/local/bin/fly

COPY ./docker-helpers.sh /
COPY ./docker-wrapper /usr/local/bin/
ENTRYPOINT [ "docker-wrapper" ]

CMD "ash"
