#!/bin/bash
set -eu

#cat migration_output.txt | \
#  awk '$2 ~ /(\[APP\/TASK\/)*/' | \
#  grep -o '{.*}' | jq '.message' -r