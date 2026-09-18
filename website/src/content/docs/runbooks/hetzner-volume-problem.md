---
title: Unable to mount an Hetzner Volume
---

# Steps

## Diagnostic

### Check the events

Kubernetes records most provisioning and mounting problems as Events:

* on the namespace
* on the PersistentVolumeClaim or the Pod:

Look at the Events section at the bottom of the output.

```bash
kubee -n namespace kubectl describe pvc <PVC-NAME>
kubee -n namespace kubectl describe pod <POD-NAME>
```

### Check the controller logs

The [controller](https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/explanation/architecture.md#controller)
is composed of the following container:

* Csi Driver (main container)

```bash
kubectl logs \
  -n kube-system -l app.kubernetes.io/name=hcloud-csi,app.kubernetes.io/component=controller \
  -c hcloud-csi-driver
```

* Resizer  (sidecar)

```bash
kubectl logs \
  -n kube-system -l app.kubernetes.io/name=hcloud-csi,app.kubernetes.io/component=controller \
  -c csi-resizer
```

* Attacher  (sidecar)

```bash
kubectl logs \
  -n kube-system -l app.kubernetes.io/name=hcloud-csi,app.kubernetes.io/component=controller \
  -c csi-attacher
```

https://github.com/hetznercloud/csi-driver/issues/46
https://github.com/k3s-io/k3s/issues/732#issuecomment-533896909

```bash
MountVolume.WaitForAttach failed for volume "combo-postgres-pv" : 
volume 106135968 has GET error for
volume attachment csi-8eec466de784837604919617e7b87cd7746d2a2e1c0d712c9d1d06025825011e: 
volumeattachments.storage.k8s.io "csi-8eec466de784837604919617e7b87cd7746d2a2e1c0d712c9d1d06025825011e" 
is forbidden: 
User "system:node:kube-server-01.eraldy.com" cannot get resource "volumeattachments" 
in API group "storage.k8s.io" at the cluster scope: no relationship found between node 'kube-server-01.eraldy.com' and this object
```

```bash
2026-06-24T20:09:46.020271099Z E0624 20:09:46.018997       1 reflector.go:204] "Failed to watch" err="pods is forbidden: User \"system:serviceaccount:kube-system:hetzner-csi-controller\" cannot watch resource \"pods\" in API group \"\" at the cluster scope" logger="UnhandledError" reflector="k8s.io/client-go/informers/factory.go:161" type="*v1.Pod"
```

### More Info

[Troubleshooting guide](https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/guides/troubleshooting.md)

## Known Error

### The file /dev/disk/by-id/scsi-0HC_Volume_xxx does not exist

Check that the volume is not attached in the Hetzner console.

If not, the `volumeattachment` must be deleted if one exists.
[as proposed on this comment](https://github.com/hetznercloud/csi-driver/issues/278#issuecomment-1273883892)

Steps:

* Check that there is an attachment and get the name (ie `csi-id`) of the `volumeattachment`

```bash
kubee kubectl get volumeattachment | grep your-pvc-name
```

* Delete it if it exists

```bash
kubee kubectl delete volumeattachment csi-id
kubee kubectl delete volumeattachment csi-0f1e84ed8e2b316a4b746d0f0xxxx
```

Example output:

```
Warning: deleting cluster-scoped resources, not scoped to the provided namespace
volumeattachment.storage.k8s.io "csi-0f1e84ed8e2b316a4b746d0f0xxxx" deleted
```

* The volume should then appear in the list of disk.

```bash
# on the node
ls -la /dev/disk/by-id/
```

```
scsi-0HC_Volume_xxxx -> ../../sdb
scsi-0HC_Volume_xxxx -> ../../sdc
```