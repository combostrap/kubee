# ArgoCd don't sync

## Check

The sync is performed by the `argocd-application-controller`.

Check that the pod is running.

## Possible Solutions

By default, during the sync, the ArgoCD controller may see some memory peak.

Therefore, we set a default limit around `400Mi`. 
The more you add manifests, the more memory it will need.

In your [cluster values file](../cluster/cluster-values.md), increase the memory value

Example:
```yaml
argocd:
  enabled: true
  hostname: 'argocd-xxx.sslip.io'
  components:
    argocd_application_controller:
      resources:
        # increase this value
        memory: '450Mi'
```