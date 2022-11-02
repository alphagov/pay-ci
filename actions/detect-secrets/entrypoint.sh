#!/bin/bash

set -euo pipefail

FILE=.secrets.baseline
if [ -f "$FILE" ]; then
    echo "$FILE found"
    git config --global --add safe.directory /github/workspace
    git ls-files -z | xargs -0 detect-secrets-hook --baseline "$FILE"
else
    echo "$FILE not found, exiting"
    exit 1
fi
