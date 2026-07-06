---
title: Environment
---

## Environment variables

The environment variables

### KUBEE_USER_NAME

`KUBEE_USER_NAME`: the connection username (default to `default`)
Used in the creation of a config file

### KUBEE_CLUSTER_NAME

`KUBEE_CLUSTER_NAME` defines the default cluster name.
You can set it also via the `-c` or `--cluster` command line option.

The cluster name is used:

* in connection
* in the detection of a cluster project

### KUBEE_CONTEXT_NAME

The context is string that concatenates the username and the cluster name

```bash
$KUBEE_USER_NAME@$KUBEE_CLUSTER_NAME
```

ie the expected value in the context file of the [kubeconfig file](kubeconfig-connection.md)

```yaml
apiVersion: v1
kind: Config
clusters: [ ]
contexts: [ ]
users: [ ]
current-context: "$KUBEE_CONTEXT_NAME"
```

If they don't match, kubee stops the cluster connection.

### KUBEE_CLUSTERS_PATH

`KUBEE_CLUSTERS_PATH` defines a list of directory path where you could find cluster definitions (environment, values and
inventory file)

Example

```bash
export KUBEE_CLUSTERS_PATH="$HOME/argocd/clusters:$HOME/argocd-2/clusters"
```

### KUBEE_CHARTS_PATH

The `$KUBEE_CHARTS_PATH` environment variable defines a path environment variable where each path is a directory that
contains
kubee charts.

It should be set in your `.bashrc`

Example:

```bash
export KUBEE_CHARTS_PATH=$HOME/my-kubee-charts:$HOME/my-other-kubee-charts
```

### KUBEE_BACKUP_DIR

The local backup directory used to download zip/tar backup archives.

```bash
KUBEE_BACKUP_DIR=${KUBEE_BACKUP_DIR:-"$HOME/.kubee/backup"}
```

It's used by the command:
* [vault backup](../command/kubee-vault.md#backup)
* [cert backup](../command/kubee-cert.md#backup)

### KUBEE_BUSYBOX_IMAGE

The image used by [kubee-shell](../command/kubee-app-shell.md) when asking for a shell in a busybox.

Default to [ghcr.io/gerardnico/busybox:latest](https://github.com/gerardnico/busybox/pkgs/container/busybox)

```bash
export KUBEE_BUSYBOX_IMAGE=ghcr.io/gerardnico/busybox:latest
```

### KUBEE_CONNECTION_NAMESPACE_DEFAULT

`KUBEE_CONNECTION_NAMESPACE_DEFAULT`: the default connection namespace.

### KUBEE_PASS_HOME

`KUBEE_PASS_HOME`: the home directory in pass (default to `kubee`) for the location of
the [connection secrets](#connection-secrets-path)

## Connection environment

### Connection namespace

Connection Namespace Order of precedence:
In order, the connection namespace value used is:

* `default` if the flag `--all-namespace` is passed
* the option value of the flag `-n|--namespace`
* [KUBEE_CONNECTION_NAMESPACE_DEFAULT](#kubee_connection_namespace_default) if it exists
* otherwise `default`

### Connection Context Name

The connection context name in the config file is derived as `$KUBEE_USER@$KUBEE_CLUSTER/$KUBEE_CONNECTION_NAMESPACE`

### Connection Secrets Path

* `client-certificate-data` : `$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-certificate-data`
* `client-key-data` : `$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-key-data`
* `client-token` : `$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-token`

## TIP

To get the env in the prompt such as cluster and namespace,
check [kube-ps1](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kube-ps1)
