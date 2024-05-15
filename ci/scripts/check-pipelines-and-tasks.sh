#!/bin/sh -ec

apk add git shellcheck
go install github.com/alphagov/paas-cf/tools/pipecleaner@latest

cd /tmp/

echo "c7d331052a6bf552b017adf5288b8e162346157c  fly-7.6.0-linux-amd64.tgz" > fly-7.6.0-linux-amd64.tgz.sha1
wget -c https://github.com/concourse/concourse/releases/download/v7.6.0/fly-7.6.0-linux-amd64.tgz -O fly-7.6.0-linux-amd64.tgz
sha1sum -c fly-7.6.0-linux-amd64.tgz.sha1
tar -O -zxf fly-7.6.0-linux-amd64.tgz > /usr/local/bin/fly
chmod u+x /usr/local/bin/fly

cd -

pipecleaner --rubocop=false ci/tasks/*.yml

find ci/pipelines -name '*.yml' | while read -r PIPELINE; do
  echo "Validating: $PIPELINE"
  fly validate-pipeline -c "$PIPELINE"
  echo
done
