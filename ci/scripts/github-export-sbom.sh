#!/bin/sh -ec

apk add --no-progress --no-cache git github-cli aws-cli
mkdir -p sbom-data/

DATE=$(date -I)
OWNER="alphagov"

# shellcheck disable=SC2046 # We specifically want to split in this case
set -- $(printf '%s\n' $(gh search repos --archived=false --owner="alphagov" --topic="govuk-pay" --limit=99 --json=name --jq ".[] | .name"))

for repo do
    file=sbom-data/${DATE}_sbom_"${repo}".json
    curl -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/${OWNER}/"${repo}"/dependency-graph/sbom \
        --output "${file}"
done

aws s3 cp sbom-data/ s3://govuk-pay-sbom-dev/"${DATE}"_github_sbom --recursive
