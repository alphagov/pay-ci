#!/usr/bin/env bash

set -euo pipefail

python3 -m venv /tmp/venv
source /tmp/venv/bin/activate

./configuration/scripts/generate-csvs.sh
