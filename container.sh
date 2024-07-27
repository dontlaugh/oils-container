#!/bin/sh

set -e

if [ $# -ne 3 ]; then
  echo "error: must provide exactly 3 parameters:"
  echo "  version, sha256 checksum, image tag"
  exit 1
fi

version="$1"
checksum="$2"
image_tag="$3"

if [ "$(id -u)" -ne "0" ]; then
  echo "error: this script must be run in a buildah unshare session, or as root"
  exit 1
fi

c1=$(buildah from docker.io/debian:stable-slim)
buildah add $c1 build.sh /root/
buildah run $c1 -- sh /root/build.sh $version $checksum

c2=$(buildah from docker.io/debian:stable-slim)

mnt1=$(buildah mount $c1)
mnt2=$(buildah mount $c2)

cp $mnt1/usr/local/bin/oils-for-unix $mnt2/usr/local/bin
cp $mnt1/usr/lib/x86_64-linux-gnu/libreadline.so.8   $mnt2/usr/lib/x86_64-linux-gnu/libreadline.so.8
cp $mnt1/usr/lib/x86_64-linux-gnu/libreadline.so.8.2 $mnt2/usr/lib/x86_64-linux-gnu/libreadline.so.8.2

buildah run $c2 -- ln -s /usr/local/bin/oils-for-unix /usr/local/bin/osh
buildah run $c2 -- ln -s /usr/local/bin/oils-for-unix /usr/local/bin/ysh

buildah commit $c2 $image_tag

buildah rm $c1
buildah rm $c2

echo "Image committed: $image_tag"
echo "Running tests"

podman run --rm $image_tag osh -c 'echo hi from osh'
podman run --rm $image_tag ysh -c 'echo hi from ysh'

echo ""
echo "Things seem okay. Push with:"
echo ""
echo "   buildah push $image_tag"

