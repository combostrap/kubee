---
title: kubee command
---

## About

`kubee` is the main entry of the `kubee platform`

## Extras


### PromTool

Validate and test PrometheusRules with [kubee-promtool](kubee-promtool.md)

### Alert Manager

Query and send alert to the Prometheus Alert Manager with [kubee-alertmanager](kubee-alertmanager.md)

### Shell

[Kubee shell](kubee-app-shell.md) - get a shell from a busybox container or a pod

### Ephemere KubeConfig stored in pass

Generate an Ephemere Kubeconfig from pass with [kubeconfig-pass](../general/kubeconfig-pass.md)

## List and documentation

* [kubee helmet](kubee-helmet.md) - the kubee chart manager
* [kubee app shell](kubee-app-shell.md) - get a shell from a busybox container or a pod
* [kubee-kapply](kubee-kapply.md) - apply a kustomize app (ie `kustomize apply`)
* [kubee-events](kubee-event.md) - shows the events of an app
* [kubee-volume-explorer](kubee-volume-explorer.md) - Explore the files of an app via SCP/SFTP
* [kubee-logs](kubee-logs.md) - print the logs of pods by app name
* [kubee-pods](kubee-pods.md) - watch/list the pods of the cluster
* [kubee-vault](kubee-vault.md) - Vault operations (init, unseal, backup, restore) 
* [kubee-app-restart](kubee-app-restart.md) - execute a rollout restart
* [kubee app top](kubee-app-top.md) - shows the top processes of an app
* [kubee cert](kubee-cert.md) - print the kubeconfig cert in plain text
* [kubee-cidr](kubee-pods-cidr.md) - print the cidr by pods
* [kubee-k3s](kubee-k3s.md) - collection of k3s utilities
* [kubee-ns](kubee-ns.md) - set or show the current namespace
* [kubee-events](kubee-events.md) - show the event of a namespace
* [kube-pods-ip](kubee-pods-ip.md) - show the ip of pods
* [kube-pvc-move](kubee-pvc-move.md) - move a pvc (Automation not finished)

## What is an app name?

In all `app` scripts, you need to give an `app name` as argument.

The scripts will try to find resources for an app:

* via the `app.kubernetes.io/instance=$APP_NAME` label
* via the `app.kubernetes.io/name=$APP_NAME` label
* or via the `.envrc` of an app directory

Problem: We need multiple apps in the same directory
because an operator may ship multiple CRD definitions.

See: `app.kubernetes.io/part-of: argocd`

Example: the Prometheus Operator

* prometheus (Prometheus CRD)
* alertmanager (AlertManager CRD)
* pushgateway
* node exporter

### What is Envrc App Definition?

In this configuration:

* All apps are in a subdirectory of the `KUBEE_APP_HOME` directory (given by the `$KUBEE_APP_HOME` environment
  variable).
* The name of an app is the name of a subdirectory
* Each app expects a `kubeconfig` file located at `~/.kube/config-<app name>` with the default context set with the same
  app namespace

## Kubectl Plugins

To make these utilities [Kubectl plugin](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/),
you can rename them from `kubee-` to `kubectl-`

They should then show up in:

```bash
kubectl plugin list
```

You can discover other plugins at [Krew](https://krew.sigs.k8s.io/plugins/)
