# Issue: App syncing causes big memory spike and CPU spike in application controller.

Syncing and starting the application controller creates spike in memory.
It goes back to a normal memory level but there is a x2 spike.

Below are the argocd parameters that controls the memory spike.

## List of Issues

* https://github.com/argoproj/argo-cd/discussions/6964#discussioncomment-1164100
* https://github.com/argoproj/argo-cd/discussions/10262

## Resolution

All perf conf are explained [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/)

### Argocd-application-controller flag

[argocd-application-controller](https://argo-cd.readthedocs.io/en/stable/operator-manual/server-commands/argocd-application-controller/)
is a controller that continuously monitors running applications and compares the current, live state against the desired
target state (as specified in the repo).

By default, `kubectl-parallelism-limit` is set to `1` in a `kubee` cluster.

You can change it via the `argocd.conf.controller_kubectl_parallelism_limit` [conf](../values.yaml)

Other important Perf Flags:

* `--status-processors`: Number of application status processors (default 1)
* `--operation-processors`: Number of application operation processors (default 1)
* `--kubectl-parallelism-limit`: Number of allowed concurrent kubectl fork/execs. Any value less the 1 means no limit. (
  default 20)

### Argocd-repo-server flag

[argocd-repo-server](https://argo-cd.readthedocs.io/en/stable/operator-manual/server-commands/argocd-repo-server/)
maintains a local cache of the Git repository holding the application manifests, and is responsible for generating and
returning the Kubernetes manifests.

Flags:

* `--parallelismlimit int` : Limit on number of concurrent manifests generate requests (manifest tool invocations). Any
  value less the 1 means no limit.

#### manifest-generate-paths

In a monorepo,
uses [argocd.argoproj.io/manifest-generate-paths](https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/#manifest-paths-annotation)
to avoid generating every single manifest on every commit.
The `argocd.argoproj.io/manifest-generate-paths` is an app annotation
that contains a semicolon-separated list of paths within the Git repository
that are used during manifest generation.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  annotations:
    # resolves to 'my-application' and 'shared'
    argocd.argoproj.io/manifest-generate-paths: .;../shared
spec:
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: my-application
# ...
```



