#!/bin/ash
# shellcheck shell=dash
set -euo pipefail

apk add --no-cache --no-progress github-cli

export MASTER="pay-ci"
export PR="pkl-pipeline-pr"

GITHUB_PR_URL=$(jq -r '.[] | select(.name == "url") | .value' < "$PR/.git/resource/metadata.json")

mkdir -p "diffs/${CONCOURSE_TEAM}/"

FAILED_EVALUATIONS_TMPFILE=$(mktemp)

for DIR in "$MASTER" "$PR"; do
  echo "Generting YML from PKL in $DIR"

  if [ ! -d "$DIR/ci/pkl-pipelines/${CONCOURSE_TEAM}" ]; then
    mkdir -p "$DIR/ci/pkl-pipelines/${CONCOURSE_TEAM}"
  fi

  cd "$DIR/ci/pkl-pipelines/${CONCOURSE_TEAM}" >> /dev/null 2>&1

  find . -mindepth 1 -maxdepth 1 -type f -name '*.pkl' | while read -r PKL_FILE; do
    echo "Generating YML for $PKL_FILE"
    YAML_FILE=$(echo "$PKL_FILE" | sed -E 's/\.pkl$/.yml/')
    if ! pkl eval "$PKL_FILE" > "$YAML_FILE"; then
      echo "$PKL_FILE" >> "$FAILED_EVALUATIONS_TMPFILE"
    fi
  done

  cd - >> /dev/null 2>&1
done

if [ "$(wc -l < "$FAILED_EVALUATIONS_TMPFILE")" -gt 0 ]; then
  echo "ERROR: Some pkl pipelines were not able to be evaluated in Concourse team $CONCOURSE_TEAM. The following pipelines failed:"
  echo 
  cat "$FAILED_EVALUATIONS_TMPFILE"
  echo
  exit 1
fi

YAML_FILES_TO_DIFF=$(
  find \
    "$MASTER/ci/pkl-pipelines/$CONCOURSE_TEAM" \
    "$PR/ci/pkl-pipelines/$CONCOURSE_TEAM" \
    -maxdepth 1 -type f -name '*.yml'
)

if [ "$(echo "$YAML_FILES_TO_DIFF" | wc -l)" -eq 0 ]; then
  echo "No YAML files to diff"
  exit 0
fi

echo "Generating diffs"
NO_DIFF_TMPFILE=$(mktemp)

echo "$YAML_FILES_TO_DIFF" | cut -f 5 -d '/' | sort | uniq | while read -r PIPELINE_YAML; do
  if diff -uN "$MASTER/ci/pkl-pipelines/$CONCOURSE_TEAM/$PIPELINE_YAML" "$PR/ci/pkl-pipelines/$CONCOURSE_TEAM/$PIPELINE_YAML" >>/dev/null 2>&1; then
    echo "No diff in $PIPELINE_YAML"
    echo "$CONCOURSE_TEAM/$PIPELINE_YAML" >> "$NO_DIFF_TMPFILE"
  else
    echo "Diff in $PIPELINE_YAML"
    set +e
    diff -uN "$MASTER/ci/pkl-pipelines/$CONCOURSE_TEAM/$PIPELINE_YAML" "$PR/ci/pkl-pipelines/$CONCOURSE_TEAM/$PIPELINE_YAML" > "diffs/${PIPELINE_YAML}"
    set -e
  fi
done

echo "Logging into concourse with fly"
fly -t "$CONCOURSE_TEAM" login -c "https://pay-cd.deploy.payments.service.gov.uk" -u "$CONCOURSE_TEAM" -p "$FLY_PASSWORD" --team-name "$CONCOURSE_TEAM"

echo "Commenting on PR"
cd diffs >>/dev/null 2>&1

if [ "$(find . -mindepth 1 -maxdepth 1 -type f -name '*.yml' | wc -l)" -eq 0 ]; then
  gh pr comment "$GITHUB_PR_URL" --body "**No YAML differences detected between PR and master pkl files in Concourse Team $CONCOURSE_TEAM**"

  exit 0
fi

find . -maxdepth 1 -mindepth 1 -type f -name '*.yml' | while read -r DIFF_FILE; do
  TMPFILE=$(mktemp)

  PIPELINE_NAME=$(basename "$DIFF_FILE" | sed -E 's/\.yml$//')
  PKL_FILE="${CONCOURSE_TEAM}/${PIPELINE_NAME}.pkl"

  {
    echo "# Changes for $PKL_FILE"
    echo
  } >> "$TMPFILE"

  if [ ! -f "../$PR/ci/pkl-pipelines/$CONCOURSE_TEAM/$DIFF_FILE" ]; then
    {
      echo "\`$PKL_FILE\` has been deleted. Would require you to run:"
      echo
      echo '```diff'
      echo "\$ fly -t \"$CONCOURSE_TEAM\" destroy-pipeline -p \"$PIPELINE_NAME\""
      echo '```'
      echo
    } >> "$TMPFILE"
  elif [ ! -f "../$PR/ci/pkl-pipelines/$CONCOURSE_TEAM/$DIFF_FILE" ]; then
    {
      echo "\`$PKL_FILE\` does not exist in master, so there is no YAML diff"
      echo
    } >> "$TMPFILE"
  else
    {
      echo "<details><summary>Diff of YAML generated from $PKL_FILE</summary>"
      echo
      echo '```diff'
      cat "$DIFF_FILE"
      echo '```'
      echo "</details>"
      echo
    } >> "$TMPFILE"

    DRY_RUN_TMPFILE=$(mktemp)
    # NOTE: The sed expressions in here removes the ansi escape codes that the very naughty
    # fly cli puts into the output despite being in --no-color mode.
    # sed -E 's/^ +\x8+//'     CTRL+H character
    # sed -E 's/\x1B\[1m//'    ANSI Enable Bold character
    # sed -E 's/\x1B\[0m//'    ANSI disable Bold character
    fly --target "$CONCOURSE_TEAM" \
      set-pipeline \
      --no-color \
      --dry-run \
      --config "../$PR/ci/pkl-pipelines/$CONCOURSE_TEAM/$DIFF_FILE" \
      --pipeline "$PIPELINE_NAME" \
      | sed -E 's/^ +\x8+//' \
      | sed -E 's/\x1B\[1m//' \
      | sed -E 's/\x1B\[0m//' \
      > "$DRY_RUN_TMPFILE"

    if grep "no changes to apply" "$DRY_RUN_TMPFILE" >>/dev/null 2>&1 && [ "$(wc -l <"$DRY_RUN_TMPFILE")" -eq 1 ]; then
      {
        echo
        echo "Concourse set-pipeline dry-run shows no changes for \`$PKL_FILE\`"
        echo
      } >> "$TMPFILE"
    else
      {
        echo
        echo "<details><summary>Concourse set-pipeline dry-run for \`$PKL_FILE\`</summary>"
        echo
        echo '```diff'
        cat "$DRY_RUN_TMPFILE"
        echo '```'
        echo
      } >> "$TMPFILE"
    fi
  fi

  if [ "$(wc -m <"$TMPFILE")" -gt 65536 ]; then
    echo "The comment is too long to attach to the PR."
    echo
    echo "================================================================================"
    echo "Diffs follows:"
    echo "================================================================================"
    cat "$TMPFILE"
    echo "================================================================================"
    echo "End Diffs"
    echo "================================================================================"
    gh pr comment "$GITHUB_PR_URL" --body "The diff for \`$CONCOURSE_TEAM/$PKL_FILE\` was too long, see concourse output"
  else
    gh pr comment "$GITHUB_PR_URL" --body-file "$TMPFILE"
  fi

  # Sleep so we don't get rate limited by the github API
  sleep 1
done

if [ "$(wc -l <"$NO_DIFF_TMPFILE")" -gt 0 ];then
  TMPFILE=$(mktemp)

  {
    echo "The following files had no diff in the YAML between the main branch and this PR:"
    echo
    echo '```'
    cat "$NO_DIFF_TMPFILE"
    echo '```'
  } >> "$TMPFILE"

  gh pr comment "$GITHUB_PR_URL" --body-file "$TMPFILE"
fi
