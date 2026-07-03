---
title: ArgoCd don't sync
---

## Check

The sync is performed by the `argocd-application-controller`.

Check that the pod is running.

## Possible Solutions

By default, during the sync, the ArgoCD controller may
see [some memory peak](../../../../../charts/argocd/contrib/argocd-cpu-memory-spikes.md)

### Increase Memory

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

### Decrease History

* On replica set

```yaml
# nonk8s
apiVersion: apps/v1
kind: Deployment
metadata:
  name: xxxx
spec:
  # Keep only 3 old ReplicaSets (default is 10)
  revisionHistoryLimit: 3
```

* On cron job (not much impact)

```yaml
# nonk8s
apiVersion: batch/v1
kind: CronJob
spec:
  # how many completed (successful) Jobs to keep (default: 3) - 0, none
  successfulJobsHistoryLimit: 0
  # how many failed Jobs to keep (default: 1)
  failedJobsHistoryLimit: 1
```
