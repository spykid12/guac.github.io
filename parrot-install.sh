#!/bin/bash

# Based on https://nest.parrotsec.org/build/alternate-install

function core_install() {
    # Protect against HTTP vulnerabilities [https://www.debian.org/security/2016/dsa-3733], [https://www.debian.org/security/2019/dsa-4371]
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get -y full-upgrade
    apt-get -y install gnupg
    [ ! -f /etc/apt/sources.list.d/debian.list ] && cp /etc/apt/sources.list /etc/apt/sources.list.d/debian.list
    echo -e "deb https://mirror.parrot.sh/mirrors/parrot/dists/rolling/InRelease" > /etc/apt/sources.list.d/parrot.list
    echo -e "# The parrot repo is located at /etc/apt/sources.list.d/parrot.list" > /etc/apt/sources.list
    gpg --keyserver hkp://keys.gnupg.net --recv-key 363A96A5CEA9EA27
    gpg --export team@parrotsec.org | apt-key add -
    apt-get update
    apt-get -y --force-yes -o Dpkg::Options::="--force-overwrite" install apt-parrot parrot-archive-keyring --no-install-recommends
    apt-get update
    apt -y --allow-downgrades -o Dpkg::Options::="--force-overwrite" install parrot-core
    echo "nameserver 168.63.129.16" > /etc/resolv.conf
    apt -y --allow-downgrades -o Dpkg::Options::="--force-overwrite" dist-upgrade
    apt -y autoremove
    parrot-mirror-selector default rolling
}

function enable_xrdp() {
    apt-get -y install xrdp
    service xrdp start
    service xrdp-sesman start
    update-rc.d xrdp enable
}

function security_install() {
    apt -y --allow-downgrades install parrot-interface parrot-interface-full parrot-tools-full
}


if [ `whoami` == "root" ]; then
    core_install;
    enable_xrdp;
    security_install;
else
    echo "R U Drunk? This script needs to be run as root!"
fi
