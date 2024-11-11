#!/usr/bin/env bash

set -euo pipefail

NUMBER_OF_DIRS=0
WORKING_DIR=

while read -r DIR; do
  NUMBER_OF_DIRS=$((NUMBER_OF_DIRS+1))
  WORKING_DIR="$DIR"
  echo ". $DIR"
done < <(find ad-hoc-sql-scripts -name 'ZD-*' -type d)

if [[ "$NUMBER_OF_DIRS" -eq 0 ]]; then
  echo "No Zendesk ticket directories found. Exiting"
  exit 0
elif [[ "$NUMBER_OF_DIRS" -ge 2 ]]; then
  echo "More than 1 Zendesk ticket directories found. Exiting"
  exit 0
fi

echo "Changing to directory $WORKING_DIR"
cd "$WORKING_DIR"

ls -la
