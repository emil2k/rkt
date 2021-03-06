# rkt image

## rkt image list

You can get a list of images in the local store with their keys, names and import times.

```
# rkt image list
ID                       NAME                            IMPORT TIME            LATEST
sha512-91e98d7f1679      coreos.com/etcd:v2.0.9          6 days ago             false
sha512-a03f6bad952b      coreos.com/rkt/stage1:0.7.0     55 minutes ago         false
```

A more detailed output can be had by adding the `--full` flag

```
ID                                                                        NAME               IMPORT TIME                          LATEST
sha512-b843248e28fa9132e23e1e763142049d17a61bab7873dff1e1ff105f9ddb2708   redis:latest       2015-09-17 13:27:04.24 +0200 CEST    true
sha512-fb6b47cc9e7ee29f67422c6585c8f517c16e0e0ee9f4cf8b8cafd8e1c1d29233   redis:latest       2015-09-17 14:57:36.779 +0200 CEST   true
```

## rkt image rm

Given an image ID you can remove it from the local store.

```
# rkt image rm sha512-a03f6bad952b
rkt: successfully removed aci for image ID: "sha512-a03f6bad952b"
rkt: 1 image(s) successfully remove
```

## rkt image gc

You can garbage collect the rkt store to clean up unused internal data and remove old images (this one to be implemented).

```
# rkt image gc
rkt: removed treestore "deps-sha512-120e20cf5c4588b9ed9727e9963f87cc587bec8f23e26fb607cb6adf6d3953f2"
```


## rkt image export

There are cases where you might want to export the ACI from the store to copy to another machine, file server, etc.

```
# rkt image export coreos.com/etcd etcd.aci
$ tar xvf etcd.aci
```

NOTES:
- A matching image must be fetched before doing this operation, rkt will not attempt to download an image first, this subcommand will incur no-network I/O.
- The exported ACI file might be different than the original one because rkt image export always returns uncompressed ACIs.


## rkt image extract/render

For debugging or inspection you may want to extract an ACI to a directory on disk. There are a few different options depending on your use case but the basic command looks like this:

```
# rkt image extract coreos.com/etcd etcd-extracted
# find etcd-extracted
etcd-extracted
etcd-extracted/manifest
etcd-extracted/rootfs
etcd-extracted/rootfs/etcd
etcd-extracted/rootfs/etcdctl
...
```

NOTE: Like with rkt image export, a matching image must be fetched before doing this operation.

Now there are some flags that can be added to this:

To get just the rootfs use:

```
# rkt image extract --rootfs-only coreos.com/etcd etcd-extracted
# find etcd-extracted
etcd-extracted
etcd-extracted/etcd
etcd-extracted/etcdctl
...
```

If you want the image rendered as it would look ready-to-run inside of the rkt stage2 then use `rkt image render`. NOTE: this will not use overlayfs or any other mechanism. This is to simplify the cleanup: to remove the extracted files you can run a simple `rm -Rf`.

## rkt image cat-manifest

For debugging or inspection you may want to extract an ACI manifest to stdout.

```
# rkt image cat-manifest --pretty-print coreos.com/etcd
{
  "acVersion": "0.7.0",
  "acKind": "ImageManifest",
...
```
