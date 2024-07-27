#!/bin/sh


if [ $# -ne 2 ]; then
  echo "supply exactly 2 args: [version, checksum]"
  echo "  see versions and their checksums at: https://www.oilshell.org/releases.html"
  exit 2
fi

release="$1"
checksum="$2"

tempdir=$(mktemp -d)
cd $tempdir > /dev/null
apt-get update -y
apt-get install -y g++ curl libreadline-dev build-essential
oils_release="oils-for-unix-${release}"

set +x
url="https://www.oilshell.org/download/${oils_release}.tar.gz"
filename=$(basename "$url")

# Download the file;  Calculate the SHA-256 hash and compare it to the expected value from the website
set -e
curl -O "$url"
downloaded_checksum=$(sha256sum "$filename" | awk '{ print $1 }')

if [ "$downloaded_checksum" = "$checksum" ]; then
    echo "Checksum verification passed."
else
    echo "Checksum verification failed."
    exit 1
fi

# build and install
tar xzf $filename
cd $oils_release
./configure
./_build/oils.sh
./install

