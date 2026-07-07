#!/usr/bin/env bash

set -euo pipefail

python3 -m venv /tmp/venv
source /tmp/venv/bin/activate
pip install -r pay-access-control/scripts/requirements.txt

./configuration/scripts/generate-csvs.sh
