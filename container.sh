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

# Instantiate a working container, build oils-for-unix
working_container1=$(buildah from docker.io/debian:stable-slim)
buildah add $working_container1 fetch-and-build.sh /root/
buildah run $working_container1 -- sh /root/fetch-and-build.sh $version $checksum

# Instantiate another working container
working_container2=$(buildah from docker.io/debian:stable-slim)

# Mount the filesystems of both working containers
mnt1=$(buildah mount $working_container1)
mnt2=$(buildah mount $working_container2)

# Copy the built binary and readline library from container 1 into container 2
# This is akin to a multi-stage build in Docker.
cp $mnt1/usr/local/bin/oils-for-unix $mnt2/usr/local/bin
cp $mnt1/usr/lib/x86_64-linux-gnu/libreadline.so.8   $mnt2/usr/lib/x86_64-linux-gnu/libreadline.so.8
cp $mnt1/usr/lib/x86_64-linux-gnu/libreadline.so.8.2 $mnt2/usr/lib/x86_64-linux-gnu/libreadline.so.8.2

# Set up the symlinks so osh and ysh are on the $PATH
buildah run $working_container2 -- ln -s /usr/local/bin/oils-for-unix /usr/local/bin/osh
buildah run $working_container2 -- ln -s /usr/local/bin/oils-for-unix /usr/local/bin/ysh

# Commit our image. It's ready to push after this.
buildah commit $working_container2 $image_tag

# Clean up.
buildah rm $working_container1
buildah rm $working_container2

# Run tests.
echo "Image committed: $image_tag"
echo "Running tests"

podman run --rm $image_tag osh -c 'echo hi from osh'
podman run --rm $image_tag ysh -c 'echo hi from ysh'

echo ""
echo "Things seem okay. Push with:"
echo ""
echo "   buildah push $image_tag"

