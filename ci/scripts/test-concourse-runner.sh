#!/bin/bash
set -eo pipefail

source /docker-helpers.sh

start_docker

docker ps -a

cd app-repo

export MAVEN_HOME=/usr/lib/mvn
export PATH=$MAVEN_HOME/bin:$PATH
export MAVEN_REPO="$PWD/.m2"

cat <<'EOF' >settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
https://maven.apache.org/xsd/settings-1.0.0.xsd">
<localRepository>${env.MAVEN_REPO}</localRepository>
</settings>
EOF

## Test docker by running app tests
mvn --global-settings settings.xml clean verify --no-transfer-progress

## Test docker scout
echo "Checking docker scout installation..."

if docker scout version >>/dev/null 2>&1; then
  echo "Docker scout is installed"
else
  echo "Error: Docker scout is not installed"
  exit 1
fi

stop_docker
