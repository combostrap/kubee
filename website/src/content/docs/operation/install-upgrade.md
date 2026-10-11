---
title: How to installation and upgrade the kubee client
---

## List

### Installation

```bash
brew install combostrap/tap/kubee
# for the actual last/dev version
brew install --HEAD combostrap/tap/kubee
```

### Version

```bash
brew list --versions combostrap/tap/kubee
```

### Upgrade

```bash
# refresh brew's package index first
brew update
# check if there is a new version
brew outdated combostrap/tap/kubee
# upgrade
brew upgrade combostrap/tap/kubee
```
