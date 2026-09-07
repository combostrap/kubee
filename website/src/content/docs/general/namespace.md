---
title: Namespace
---

The [kubee cli](../command/kubee.md) retrieves the [connection](kubeconfig-connection.md) `namespace` in this order:

* command line option (`-n`)
* the `KUBEE_CONNECTION_NAMESPACE` env
* otherwise `default`

For Kubee chart installation, the namespace is
defined [in the values file of a kubee chart](../helmet/helmet-chart.md#values-file)