FROM python:3.11.0-alpine3.16@sha256:610aac6d972a31b2d4174a8b260e2cdf69de2d73cf03f4131ca24e61157f34d6

RUN apk update && apk upgrade
RUN apk add bash git
RUN pip install detect-secrets
