#!/bin/bash
# Simple helper script to set the env vars for the smoke test app which is
# done infrequently.

# enable the use of `pay-low-pass` alias.
shopt -s expand_aliases
source ~/.bash_profile

ENVIRONMENT="${1:?Provide environment: test|staging}"

echo "switching to 'smoke-tests' space"
cf t -s smoke-tests

cf set-env smoke-tests-"$ENVIRONMENT" SELFSERVICE_OTP_KEY "$(pay-low-pass smoke-test-users/sandbox/otp-token)"

cf set-env smoke-tests-"$ENVIRONMENT" SELFSERVICE_PASSWORD "$(pay-low-pass smoke-test-users/sandbox/password)"

cf set-env smoke-tests-"$ENVIRONMENT" SELFSERVICE_USERNAME "$(pay-low-pass smoke-test-users/sandbox/username)"

cf set-env smoke-tests-"$ENVIRONMENT" SMOKE_TEST_PRODUCT_PAYMENT_LINK_URL "https://products.${ENVIRONMENT}.gdspay.uk/redirect/smoke-tests-sandbox/products-sandbox-smoke-tests"

echo "Now create an api token via selfservice and set it with:"
echo "cf set-env smoke-tests-${ENVIRONMENT} CARD_SANDBOX_API_TOKEN <token>"

echo "now restage smoke-tests-${ENVIRONMENT}"

