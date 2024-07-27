# oils-container

YSH (and OSH) shell in a container

## Build

Install `buildah`.

Provide a release version, its checksum, and set a tag for your image. Available
releases are listed at https://www.oilshell.org/releases.html

```
version="0.22.0"
checksum="7ad64ad951faa9b8fd310fc17df0a93291e041ab75311aca1bc85cbbfa7ad45f"
image_tag="quay.io/chroot.club/oils:v${version}-debian"
```

Run the following commands.

```
buildah unshare ./container.sh $version $checksum $image_tag
```

An `unshare` session is required, because our container.sh script
mounts the root filesystems of two working containers. This operation
would require root privileges otherwise. See `man buildah-unshare`.


