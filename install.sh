#!/bin/sh

DIR="$1"
if [ -z "$DIR" ]; then
  echo "You must specify an output directory" >&2
  exit 1
fi

URL_BASE="https://github.com/overview/overview-integration-tester"
RAW_URL_BASE="https://raw.githubusercontent.com/overview/overview-integration-tester"

VERSION=$(curl "$RAW_URL_BASE/master/VERSION")

echo "Creating/overwriting files in $DIR..." >&2

(mkdir -p "$DIR" \
  && cd "$DIR" \
  && curl "$URL_BASE/archive/$VERSION.tar.gz" \
    | tar zxv skeleton --strip-components=1
)
