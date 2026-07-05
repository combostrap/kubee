# Release

## List

* To test jsonnet processing, run a postprocessing chart such as argocd
* Delete all `jsonnet/vendor` directory in release

##

A release happens with the [release script](../scripts/release)

```bash
release # will release a snapshot
release patch # will release a patch ie 0.0.x
release minor # will release a minor ie 0.x.0
release major # will release a major ie x.0.0
```

Then

```bash
brew upgrade kubee
brew info kubee
```
