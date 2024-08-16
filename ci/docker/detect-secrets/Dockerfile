FROM python:3.11.0-alpine3.20@sha256:700b4aa84090748aafb348fc042b5970abb0a73c8f1b4fcfe0f4e3c2a4a9fcca

RUN apk update && apk upgrade
RUN apk add bash git
RUN pip install detect-secrets
