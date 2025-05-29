#!/bin/bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
. lib.sh

main() {
    local version="10.0.0.0~jammy-1"
    install_packages wget

    dpkg --add-architecture i386

    # winehq APT repository temporarily disabled since, as of 2025-05-29,
    # apt-get update fails on InRelease due to Packages.gz mismatch

    # add repository for latest wine version and install from source
    # hardcode version, since we might want to avoid a version later.
    #wget -nc https://dl.winehq.org/wine-builds/winehq.key

    # workaround for wine server synchronization, see #1035
    # we need to ensure the keys are now stored in `/etc/apt/keyrings`,
    # which were previously stored in `/usr/share/keyrings`, and ensure
    # our sources list searches for the right location.
    #mkdir -p /etc/apt/keyrings
    #mv winehq.key /etc/apt/keyrings/winehq-archive.key

    #wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    #mv winehq-jammy.sources /etc/apt/sources.list.d/
    #sed -i s@/usr/share/keyrings/@/etc/apt/keyrings/@ /etc/apt/sources.list.d/winehq-jammy.sources || true

    # winehq requires all the dependencies to be manually specified
    # if we're not using the latest version of a given major version.
    #apt-get update
    #apt install --no-install-recommends --assume-yes \
    #    "wine-stable=${version}" \
    #    "wine-stable-amd64=${version}" \
    #    "wine-stable-i386=${version}" \
    #    "winehq-stable=${version}"

    # manual download and install for wine packages
    local winehq_main="https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main"
    wget ${winehq_main}/binary-amd64/wine-stable_${version}_amd64.deb
    wget ${winehq_main}/binary-amd64/wine-stable-amd64_${version}_amd64.deb
    wget ${winehq_main}/binary-i386/wine-stable-i386_${version}_i386.deb
    wget ${winehq_main}/binary-amd64/winehq-stable_${version}_amd64.deb
    apt install --no-install-recommends --assume-yes \
        ./wine-stable_${version}_amd64.deb \
        ./wine-stable-amd64_${version}_amd64.deb \
        ./wine-stable-i386_${version}_i386.deb \
        ./winehq-stable_${version}_amd64.deb

    purge_packages
}

main "${@}"
