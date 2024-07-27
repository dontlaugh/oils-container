# oils-container

[![Container Repository on Quay](https://quay.io/repository/chroot.club/oils/status "Container Repository on Quay")](https://quay.io/repository/chroot.club/oils)

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

## Usage

Oils is actually two shells

* `osh` - a new POSIX-compatible shell implementation to run your existing scripts
* `ysh` - a brand new shell language with better defaults, structured
          data types, and more

Currently, both shells are implemented by the `oils-for-unix` binary, and are
invoked via symlinks. The language (YSH or OSH) is chosen at runtime based on
whether `ysh` or `osh` is invoked.

Anyway, do one of these.

```
podman run --rm quay.io/chroot.club/oils:v0.22.0-debian osh -c 'echo hi from a POSIX shell'
podman run --rm quay.io/chroot.club/oils:v0.22.0-debian ysh -c '
    var wow = { native: ["json", "support"] }
    echo "omg a new shell with"
    json write (wow)
'
```

