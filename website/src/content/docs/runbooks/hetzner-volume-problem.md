# Steps

## Diagnostic

### Check the events

Kubernetes records most provisioning and mounting problems as Events:

* on the namespace
* on the PersistentVolumeClaim or the Pod:

Look at the Events section at the bottom of the output.

```bash
kubee kubectl describe pvc <PVC-NAME>
kubee kubectl describe pod <POD-NAME>
```

### Check the controller logs

The [controller](https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/explanation/architecture.md#controller) is composed of the following container: 
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

### More - https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/guides/troubleshooting.md

[c](https://github.com/hetznercloud/csi-driver/blob/main/docs/kubernetes/guides/troubleshooting.md)