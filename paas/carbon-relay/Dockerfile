FROM bodsch/docker-carbon-relay-ng:0.11.0

RUN apk update && apk add --update stunnel ca-certificates

ADD ./start-stunnel.sh /start-stunnel.sh
RUN chmod +x /start-stunnel.sh

