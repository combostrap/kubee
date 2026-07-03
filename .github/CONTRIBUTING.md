# Dev / Contribute

## Dev

### How to develop kubee

* The scripts are:
  * located in [bin](../bin)
  * written in `bash`
* Dependencies: You should install [bash-lib](https://github.com/gerardnico/bash-lib)

### How develop the kubee charts

Check the [helmet-chart-dev documentation](../website/src/content/docs/helmet/helmet-chart-dev.md)

### Before each commit/release

To generate docs and schema:

```bash
task all
```

## Stable and Next Version

### Stable Version

The last stable `kubee` version can be installed locally via brew

```bash
kubee --help
```

### Next Version

To call the next version iteration you can create an alias (in your `.bashrc`)

Example:

```bash
alias nkubee=$HOME/code/kubee/bin/kubee
```

