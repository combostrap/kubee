---
title: KUBECONFIG with pass
---


If `kubee` does not find:

* a `KUBECONFIG` env
* or a `~/.kube/config` file,

it will try to retrieve the the [kubeconfig file](kubeconfig-connection.md) from [the pass store](pass.md).

I will execute the following command:

```bash
pass "$KUBEE_PASS_HOME/kubeconfig/$KUBEE_CONTEXT_NAME"
```

where:

* `$KUBEE_PASS_HOME` is the path prefix in [pass](pass.md) (default to `kubee`)
* `$KUBEE_CONTEXT_NAME` is the [kubeconfig context name](kubeconfig-connection.md#context) (default to the value
  `default@$KUBEE_CLUSTER_NAME`)

With the default value, the command is:

```bash
pass "kubee/kubeconfig/default@$KUBEE_CLUSTER_NAME"
```

It's a `zero-trust` connection tool.


## Env

* `KUBEE_CLUSTER_NAME`: The cluster to connect (default to `default`)
* `KUBEE_CLUSTER_SERVER_IP`: the server ip used by default
* `KUBEE_USER_NAME`: The user to connect with (default to `default`)
* `KUBEE_PASS_HOME`: The name directory where to store `kubee` pass information (default to `kubee`)
* `KUBEE_CONNECTION_NAMESPACE`: the connection namespace (default to the app namespace or to the
  KUBEE_DEFAULT_NAMESPACE)
* `KUBEE_CHART_NAMESPACE`: the chart namespace found in the chart values file.

## How to store kubeconfig in pass ?

```bash
# The pass home directory (default to kubee)
export KUBEE_PASS_HOME="kubee"
# The cluster name
export KUBEE_CLUSTER_NAME="your-cluster-name"

# Store it
cat $HOME/.kube/config | pass insert -m "$KUBEE_PASS_HOME/kubeconfig/default@$KUBEE_CLUSTER_NAME"
```

## How to see the generated config file

```bash
kubee kubectl config view
```

## How to test

```bash
kubee kubectl cluster-info
```
