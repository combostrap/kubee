---
title: kubee-helmet
---

[//]: # (% kubee-helmet&#40;1&#41; Version Latest | Helm with Extra's)

## NAME

`kubee helmet` is the `kubee` chart manager.

## Features

### New

`kubee helmet` is a [Helm](https://helm.sh/) cli that adds support for:

* `Jsonnet` - to add [Prometheus Mixin](https://monitoring.mixins.dev/) support
* `kustomize` - to add support for application without Helm Chart such as ArgoCd.
* a cluster values file - to share cluster wide configuration between charts

### Familiar

`kubee helmet` is based on well-supported Kubernetes tools:

* [Helm](https://helm.sh/), the official kubernetes package manager
* [Kustomize](https://github.com/kubernetes-sigs/kustomize), the official manifest customization tool
* [Jsonnet Kubernetes](https://jsonnet.org/articles/kubernetes.html), the Google configuration language

It just executes [Helm commands](https://helm.sh/docs/helm/helm/) and therefore
installs [Helm Charts](https://helm.sh/docs/topics/charts/)

All new installations:

* have a [history (ie revision)](https://helm.sh/docs/helm/helm_history/)
* can be [rollback](https://helm.sh/docs/helm/helm_rollback/)
* can be [diffed](https://github.com/databus23/helm-diff)

There is no magic. All commands are:

* bash command,
* printed to the shell (visible)
* and can be re-executed at wil

## Commands

### Helmet - Play / Template

```bash
kubee [kubee option] helmet [helmet options] command chart-name
# example
nkubee --cluster "$KUBEE_CLUSTER_NAME" helmet --skip-schema-validation play external-secret
```

where options are:

- `--show-only` - dry run
- `--force` - with force
- `--out`, `--out-dir`, `-o` - the output directory for the template
- `--skip-schema-validation` - skip the schema validation

### Helm - List all installed charts

```bash
kubee helm list --all-namespaces
kubee helm list -A
```

## FAQ

### What is a Kubee Helmet hart?

[What is a Kubee Helmet Chart](../helmet/helmet-chart.md)

### What is a Jsonnet Helmet Chart?

[What is a Jsonnet Kubee Chart](../helmet/jsonnet-chart.md)

### What is the format of a Cluster Values file?

Rules:

* Hard: Every root property in a cluster values file is the alias name of the chart in `snake_case`.
* Soft: Every property name should be written in `snake_case`
  * Why? `hyphen-case` is not supported by Helm Template (ie Go template)
  * Why Not in `CamelCase`? So that we get used to the fact that we don't use `-` as a separator

Example:

```yaml
chart_1:
  hostname: foo.bar
  issuer_name: julia
chart_2:
  hostname: bar.foo
  dns_zones: [ ]
```

`kubee helmet` will transform it in a compliant Helm values.

You can see the Helm values:

* to be applied with:

```bash
kubee helmet --cluster clusterName values chartName
```

* applied with:

```bash
helm get -n namespace values chartName
```

## Note

### Secret Security

With Helm, you retrieve the applied data (manifests, values) from a storage backend.

The default storage backend for Helm is a `Kubernetes secret`,
therefore the security is by default managed by Kubernetes RBAC.

Example:
With this command, if you have access to the Kubernetes secret,
you should be able to see the applied values files with eventually your secrets.

```bash
helm get -n namespace values chartReleaseName
```

More information can be found in
the [storage backend section](https://helm.sh/docs/topics/advanced/#configmap-storage-backend)
