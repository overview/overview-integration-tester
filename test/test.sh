#!/bin/sh

DIR="$(dirname "$0")"

rm -rf "$DIR"/framework
cp -av "$DIR"/../skeleton "$DIR"/framework
cp -av "$DIR"/files-atop-framework/* "$DIR"/framework/
sed -ie 's/^WAIT_FOR_URLS=.*/WAIT_FOR_URLS="http:\/\/overview-web"/' "$DIR"/framework/config
"$DIR"/framework/run-in-docker-compose
#"$DIR"/framework/run spec/login_spec.rb
#"$DIR"/framework/run-browser ./all-tests
