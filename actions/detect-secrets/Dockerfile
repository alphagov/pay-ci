FROM python:alpine3.16

RUN apk update && apk upgrade
RUN apk add bash git
RUN pip install detect-secrets

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
