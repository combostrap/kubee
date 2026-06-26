# Contrib/Dev

## About

This is a `Kubee`:
* [kustomization chart](../../../docs/bin/kubee-helm-post-renderer.md#kustomization) because this is the official supported installation (ie [Helm is community maintained](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#helm))
* and [Jsonnet chart](../../../docs/bin/kubee-jsonnet.md) to install the monitoring mixin


## Dependency Script

Run [utilties/dl-dependency-scripts](dl-dependency-scripts) to update to the last [mixin library](../jsonnet/kubee/mixin.libsonnet)

## How to


### Test/Check values before installation

With Helmet For instance, to check the [repo creation](../templates/resources/argocd-secret-repo.yaml)
```bash
kubee helmet -c clusterName template --out argocd
```

## Namespace

https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#installing-argo-cd-in-a-custom-namespace

### Debug Notifications

* Apply the patch
```bash
kubectl patch cm argocd-notifications-cm -n argocd --type merge --patch-file argo/patches/argocd-notifications-config-map-patch.yml
```
* Test
```bash
kubectl config set-context --current --namespace=argocd
argocd admin notifications template get
```


### ArgoCd Version

The ArgoCd version is:
* in the [URL path of the kustomization file](../kustomization.yml)
* in the [appVersion of the Chart manifest](../Chart.yaml)

## Support

### Upgrade Doc

Breaking change are between minor version. ie 3.3 to 3.4
https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/

### On Upgrade, ArgoCd Controller 

ArgoCd Controller may need to:
* be restarted manually as it's a StatefulSet
* or even to delete the pods to update it
