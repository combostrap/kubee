# CHANGELOG

## [Unreleased]

New:

* Added `cluster-tls` in the [cert command](website/src/content/docs/command/kubee-cert.md) to read a TLS cert of the
  server
* Runbook: [Unable to connect to the hosts with ansible](website/src/content/docs/runbooks/unable-to-connect-to-hosts.md)

Upgrade:

* ArgoCd has been upgraded to `v3.4.4`
* The [cluster creation](website/src/content/docs/cluster/cluster-creation.md) page has been upgraded with a lot more info, details and step

Fix:

* Jsonnet command of `kubee-helm-post-render` used `sh` instead of `bash`
* When the host was not in the `~/.ssh/known_hosts`, an ansible connection would fail.
  * With `ANSIBLE_SSH_ARGS="-o StrictHostKeyChecking=accept-new"`, the host key is added automatically.