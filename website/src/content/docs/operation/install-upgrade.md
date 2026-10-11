---
title: How to install and upgrade the kubee client
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
kubee --version
# or
brew list --versions kubee
brew list --versions combostrap/tap/kubee
```

### Upgrade

```bash
# refresh brew's package index first
brew update
# check if there is a new version
brew outdated kubee
brew outdated combostrap/tap/kubee
# upgrade
brew upgrade kubee
brew upgrade combostrap/tap/kubee
```
