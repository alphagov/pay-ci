#!/bin/sh -e

# rewrite the submodule url for https to add the token.
# The risk of setting the token in the url is mitigated since these files are not committed,
# the container is ephemeral and anyone with access to read the files could read the token from
# environment variable. Furthermore we redact the token from the files after the update.
sed -i "s/https:\/\/github.com/https:\/\/${GH_ACCESS_TOKEN}@github.com\//" .gitmodules
git submodule init -q data
git submodule update data
sed -i "s/${GH_ACCESS_TOKEN}/token_redacted/" .gitmodules
sed -i "s/${GH_ACCESS_TOKEN}/token_redacted/" .git/config
