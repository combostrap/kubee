# CHANGELOG

## [Unreleased]

Fix:

* Errors on jsonnet postprocessing due:
  * to a space (L223 of kubee-helm-post-renderer)
  * jsonnet vendor symlink, not copied

## 0.1.2

New:

* Added `cluster-tls` in the [cert command](website/src/content/docs/command/kubee-cert.md) to read a TLS cert of the
  server

Runbook: [Unable to connect to the hosts with ansible](website/src/content/docs/runbooks/unable-to-connect-to-hosts.md)

* Checking that the current kubeconfig context matches `$KUBEE_USER_NAME@$KUBEE_CLUSTER_NAME`
* Added Dex as IDC on ArgoCd if the argocd client is not empty
* [Context checking on discovered kubeconfig](website/src/content/docs/general/kubeconfig-connection.md#context-check-for-cluster-connection)

Breaking:

* [pass stores now a complete kubeconfig](website/src/content/docs/general/kubeconfig-pass.md) and does not built it
  from user and cluster info (easier)

Upgrade:

* ArgoCd has been upgraded to `v3.4.4`
* The [cluster creation](website/src/content/docs/cluster/cluster-creation.md) page has been upgraded with a lot more
  info, details and step

Fix:

* Jsonnet command of `kubee-helm-post-render` used `sh` instead of `bash`
* When the host was not in the `~/.ssh/known_hosts`, an ansible connection would fail.
  * With `ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=accept-new"`, the host key is added automatically.
* Bug in [trust manager](charts/cert-manager/README.md) where the name of the bundle was not consistent between
  authorizedSecrets and bundle_name