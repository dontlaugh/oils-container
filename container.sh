#!/bin/sh

set -e

version="0.22.0"
checksum="7ad64ad951faa9b8fd310fc17df0a93291e041ab75311aca1bc85cbbfa7ad45f"
image_tag="quay.io/chroot.club/oils:v${version}-debian"

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

