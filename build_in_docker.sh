#!/usr/bin/env bash

_die() {
    echo "err: $*"
    exit 1
}

[ -d rgb-lib ] || _die "missing submodule dir"
mkdir -p dist

docker build -t rgb-lib-python .

docker run --rm -it \
    -e MYUID="$(id -u)" -e MYGID="$(id -g)" \
    -v "$(pwd)/rgb-lib:/opt/rgb-lib-python/rgb-lib" \
    -v "$(pwd)/dist:/opt/rgb-lib-python/dist" \
    rgb-lib-python \
        "./generate.sh && poetry build"
