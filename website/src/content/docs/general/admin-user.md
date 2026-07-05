---
title: Kubee Cluster Admin User
---


The `admin user` is the user that will be set as the admin of all applications
installed in the [cluster](../cluster/cluster.md)


## Definition

It's defined as values of the [cluster kubee chart](https://github.com/combostrap/kubee/tree/main/charts/cluster)

Example in your [cluster values file](../cluster/cluster-values.md)
```yaml
cluster:
  auth:
    admin_user:
      username: 'admin'
      password: '${ADMIN_PASSWORD}'
      email: 'admin@mydomain.tld'
```
