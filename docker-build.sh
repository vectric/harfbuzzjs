#!/bin/bash
set -e

cd "$EMSDK" && . ./emsdk_env.sh
cd "$EMSDK"/upstream/emscripten && npm ci
echo "## Done setting up emscripten"
cd /src
./build.sh
./build-subset.sh
echo "## Done building"
