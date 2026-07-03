---
title: kubeconfig
---

`kubeconfig` is the file that permits to connect to a Kubernetes cluster.

## How To

### How to see the kubeconfig file

```bash
kubee kubectl config view
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

