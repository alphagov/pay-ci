#!/bin/bash
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -sha256 -keyout keys/$1.key -out certs/$1.crt -subj "/CN=$1/O=GOV.UK Pay/C=GB"
