# oils-container

YSH (and OSH) shell in a container

## Build

Install `buildah`.

Provide a release version and its checksum. Set a tag for your image.

```
version="0.22.0"
checksum="7ad64ad951faa9b8fd310fc17df0a93291e041ab75311aca1bc85cbbfa7ad45f"
image_tag="quay.io/chroot.club/oils:v${version}-debian"
```

Run the following commands.

```
c=$(buildah from docker.io/debian:stable-slim)
buildah add $c build.sh /root/
buildah run $c -- sh /root/build.sh 0.22.0
c2=$(buildah from docker.io/debian:stable-slim)

buildah copy
```


