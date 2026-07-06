---
title: kubee cert command
---

[//]: # (% kubee-cert&#40;1&#41; Version Latest | Print kubernetes certificates in plain text)

## Overview

Print cert in plain text

## Commands

### config-client (Kubeconfig client)

The cert in [kubeconfig](../general/kubeconfig-connection.md) at `user.client-certificate-data`

```bash
export KUBECONFIG=~/.kube/config
kubee cert config-client
```

### config-certificate-authority (Kubeconfig cluster TLS CA)

The cert in [kubeconfig](../general/kubeconfig-connection.md) at `cluster.certificate-authority-data`

It's the cert that signed the cluster certification used by `kubeconfig` to authenticate the server.

```bash
export KUBECONFIG=~/.kube/config
kubee cert config-certificate-authority
```

### cluster-tls (Cluster TLS Cert)

The TLS cert of the server at `cluster.server`

It's the cert that is presented to `kubeconfig` to authenticate the server.

```bash
export KUBECONFIG=~/.kube/config
kubee cert cluster-tls
```

### secret-tls (TLS Cert stored as secret in Kubernetes)

Print the tls certificate stored in a secret in plain text

```bash
export KUBECONFIG=~/.kube/config
kubee cert secret-tls
```

It executes a `kubectl get secret` with a selection at `.data.tls.crt`

### secret-ca (CA Cert stored as secret in Kubernetes)

Print the ca certificate stored in a secret in plain text

```bash
export KUBECONFIG=~/.kube/config
kubee cert secret-ca
```

It executes a `kubectl get secret` with a selection at `.data.ca.crt`

### backup

The backup command downloads:

* the cert manager resources. ie `issuer`,`clusterissuer` and `cert` resources
* the issued tls secret

in the [backup directory](../general/kubee-env.md#kubee_backup_dir)

### restore

The restore command applies in a `out-of-place` mode, meaning that it will not restore / filter out:

* the `sslip.io` and `nip.io` cert and tls secret resources
* the `kube-system` resources to not replace the API `k3s-serving` certs.

Example:

```bash
kubee --cluster $KUBEE_CLUSTER_NAME cert restore
```
