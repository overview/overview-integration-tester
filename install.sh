#!/bin/sh

set -e

DIR="$1"
if [ -z "$DIR" ]; then
  echo "You must specify an output directory" >&2
  exit 1
fi

URL_BASE="https://github.com/overview/overview-integration-tester"
RAW_URL_BASE="https://raw.githubusercontent.com/overview/overview-integration-tester"

VERSION=$(curl -qLs "$RAW_URL_BASE/master/VERSION")

echo "Creating/overwriting files in $DIR..." >&2

(mkdir -p "$DIR" \
  && cd "$DIR" \
  && curl -qLs "$URL_BASE/archive/v$VERSION.tar.gz" \
    | tar zxv overview-integration-tester-$VERSION/skeleton --strip-components=2
)
