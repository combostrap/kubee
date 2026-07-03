---
title: Cluster Initial Provisioning example
---

This page is about the initial provisioning of a cluster with the minimal set of charts.

Example:

```bash
export KUBEE_CLUSTER_NAME=xxx
kubee helmet play traefik # reverse proxy
kubee helmet play prometheus # monitoring
kubee helmet play grafana # monitoring
kubee helmet play cert-manager # cert-manager
kubee helmet play oauth2-proxy # authentication
kubee helmet play vault # vault for secret
kubee helmet play external-secrets # secret sync
kubee helmet play argocd # devops
```

Once installed, you can list them:

```bash
helm list --all-namespaces
```
