#!/bin/ash
# shellcheck shell=dash
set -euo pipefail

cd src

git fetch origin main:main
git diff --name-only --diff-filter=d main~ main | xargs -n 1 dirname | grep '^bin-ranges-' | cut -f 1 -d "/" |  uniq > submodules.txt
echo "Submodules to build:"
cat submodules.txt

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

PACKAGE_VERSION="1.0.$(date +"%Y%m%d%H%M%S")"
echo "PACKAGE_VERSION=$PACKAGE_VERSION"
mvn versions:set -DnewVersion="$PACKAGE_VERSION"

while read -r line; do
  mvn --global-settings settings.xml clean install --projects "$line" --also-make
done < submodules.txt

while read -r line; do
  ls -alh "$line"/target
  mkdir ../build/"$line"
  cp "$line"/target/"$line"-*.jar ../build/"$line"
done < submodules.txt

cd ..
echo "Folders written to in build directory:"
ls -alh build