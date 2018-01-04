#!/bin/bash

DIR="$(dirname "$0")"

#if (cd "$DIR" && git status --short | grep -E '.'); then
#  echo "You have unsaved changes. Please git commit or reset them and run this again." >&2
#  exit 1
#fi

if [ -n "$(echo "v$1" | sed -e 's/v[0-9]*\.[0-9]*\.[0-9]//')" ]; then
  echo "Usage: $0 VERSION, where VERSION is like '1.0.0'" >&2
  exit 1
fi

PATCH_VERSION="$1"
MINOR_VERSION="${PATCH_VERSION%.*}"
MAJOR_VERSION="${MINOR_VERSION%.*}"

version_too_small() {
  echo "Cannot release v${PATCH_VERSION} because the latest release on this branch is already ${OLD_PATCH_VERSION}." >&2
  exit 1
}

OLD_PATCH_VERSION="$(cat "$DIR"/VERSION)"
MAJOR_VERSION_INT=$(echo $PATCH_VERSION | cut -d. -f1)
MINOR_VERSION_INT=$(echo $PATCH_VERSION | cut -d. -f2)
PATCH_VERSION_INT=$(echo $PATCH_VERSION | cut -d. -f3)
OLD_MAJOR_VERSION_INT=$(echo $OLD_PATCH_VERSION | cut -d. -f1)
OLD_MINOR_VERSION_INT=$(echo $OLD_PATCH_VERSION | cut -d. -f2)
OLD_PATCH_VERSION_INT=$(echo $OLD_PATCH_VERSION | cut -d. -f3)
if [ $MAJOR_VERSION_INT -lt $OLD_MAJOR_VERSION_INT ]; then version_too_small; fi
if [ $MAJOR_VERSION_INT -eq $OLD_MAJOR_VERSION_INT ] && [ $MINOR_VERSION_INT -lt $OLD_MINOR_VERSION_INT ]; then version_too_small; fi
if [ $MAJOR_VERSION_INT -eq $OLD_MAJOR_VERSION_INT ] && [ $MINOR_VERSION_INT -eq $OLD_MINOR_VERSION_INT ] && [ $PATCH_VERSION_INT -le $OLD_PATCH_VERSION_INT ]; then version_too_small; fi

docker build \
  --pull \
  -t overview/overview-integration-tester:$PATCH_VERSION \
  -t overview/overview-integration-tester:$MINOR_VERSION \
  -t overview/overview-integration-tester:$MAJOR_VERSION \
  "$DIR"/docker

docker push overview/overview-integration-tester:$PATCH_VERSION
docker push overview/overview-integration-tester:$MINOR_VERSION
docker push overview/overview-integration-tester:$MAJOR_VERSION

echo "$PATCH_VERSION" > "$DIR"/VERSION
(cd "$DIR" \
  && echo "$PATCH_VERSION" > VERSION \
  && sed -i -e \
    "s/^OVERVIEW_INTEGRATION_TESTER_VERSION=.*/OVERVIEW_INTEGRATION_TESTER_VERSION=$PATCH_VERSION/" \
    skeleton/config \
  && git add VERSION skeleton/config \
  && git commit -m "v$PATCH_VERSION" \
  && git tag "v$PATCH_VERSION" \
  && git push origin "v$PATCH_VERSION")
