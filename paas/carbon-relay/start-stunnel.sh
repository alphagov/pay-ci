#!/bin/sh

set -o errexit -o nounset -o pipefail

HG_ACCOUNT_ID=${HG_ACCOUNT_ID}

cat << EOF > /etc/stunnel/hg-tls.conf
foreground = yes
client = yes
accept = 20031
connect = ${HG_ACCOUNT_ID}.carbon.hostedgraphite.com:20030
verify = 2
CApath = /etc/ssl/certs
EOF

exec /usr/bin/stunnel /etc/stunnel/hg-tls.conf