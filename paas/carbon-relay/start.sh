#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

erb stunnel.conf.erb > stunnel.conf
erb carbon-relay-ng.ini.erb > carbon-relay-ng.ini

stunnel stunnel.conf hosted_graphite &
carbon-relay-ng carbon-relay-ng.ini

