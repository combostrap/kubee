---
title: kubeconfig
---

`kubeconfig` is the file that permits to connect to a Kubernetes cluster.

It contains:

* cluster information
* user information
* and context

The context is the pair user / cluster that is used to connect.

## Order of Precedence

Kubee search the kubeconfig file in the following order:

* the `KUBECONFIG` env
* the default kubeconfig file `~/.kube/config`
* in the [pass](kubeconfig-pass.md) at `$KUBEE_PASS_HOME/kubeconfig/$KUBEE_CONTEXT_NAME`

## Context check for cluster connection

To be sure that the command are executed against the required cluster,
kubee checks that the kubeconfig current context is equal to the [KUBEE_CONTEXT_NAME](kubee-env.md#kubee_context_name).

ie the expected value should be:

```yaml
apiVersion: v1
kind: Config
clusters: [ ]
contexts: [ ]
users: [ ]
current-context: "$KUBEE_CONTEXT_NAME"
```

If it's not the case, it will try to change it and if it does not succeed, it will exit.

## How To

### How to see the kubeconfig file

```bash
# with the cert cached
kubee kubectl config view
# with all data
kubee kubectl config view --raw
```

### How to test a connection

```bash
kubee kubectl cluster-info
```

### How to encrypt

We allow encryption with [pass](kubeconfig-pass.md)

## Support/Runbook

### Unable to connect

Check [the unable to connect runbook](../runbooks/kubectl-unable-to-connect.md)

