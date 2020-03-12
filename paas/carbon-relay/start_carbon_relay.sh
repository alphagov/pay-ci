#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

erb carbon-relay-ng.ini.erb > carbon-relay-ng.ini
carbon-relay-ng carbon-relay-ng.ini
