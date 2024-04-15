#!/bin/ash

set -euo pipefail

git config --global user.email "concourse-pools-init@concourse.local"
git config --global user.name "Concourse init-lock-pools job"

git init .

if [ -z "$POOLS_TO_INIT" ]; then
  echo "ERROR: Must set POOLS_TO_INIT env var to a non-empty string, this should be a comma separated list of pools to init."
  exit 1
fi

for POOL in $(echo "$POOLS_TO_INIT" | tr "," "\n"); do
  echo "Making Pool $POOL"
  mkdir -p "$POOL/claimed"
  mkdir -p "$POOL/unclaimed"
  touch "$POOL/claimed/.gitkeep"
  touch "$POOL/unclaimed/.gitkeep"
  git add "$POOL"
  git commit -m "Setup $POOL"
done