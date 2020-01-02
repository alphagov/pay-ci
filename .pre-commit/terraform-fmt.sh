#!/usr/bin/env bash

set -o errexit

for tf in $@; do
  terraform fmt -check -diff "$tf"
done
