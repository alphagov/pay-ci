#!/bin/ash
# shellcheck shell=dash

# Image definitions are going to be of one of the forms:
#
#   image_name:tag
#   image_name:tag@sha256:<sha>
#   image_name@sha256

set -euo pipefail

if [ ! -f "$DOCKERFILE" ]; then
  echo "Error: Dockerfile $DOCKERFILE not found"
  exit 1
fi

BASE_IMAGE=$(grep "^FROM " "$DOCKERFILE" | awk '{ print $2; }' | sort | uniq)

if [ "$(echo "$BASE_IMAGE" | wc -l)" -ne 1 ]; then
  echo "Error: There's not exactly a single unique FROM line definition in the Dockerfile, can't extract a single tag"
  exit 1
fi

IMAGE_AND_TAG=$(echo "$BASE_IMAGE" | cut -f 1 -d "@")
TAG=$(echo "$IMAGE_AND_TAG" | cut -f 2 -d ":")

echo "$TAG" | tee tags/tag
