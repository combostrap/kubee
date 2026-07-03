# CHANGELOG

## [Unreleased]

New:

* Added `cluster-tls` in the [cert command](website/src/content/docs/command/kubee-cert.md) to read a TLS cert of the
  server

Upgrade:

* ArgoCd has been upgraded to `v3.4.4`

Fix:

* Jsonnet command of `kubee-helm-post-render` used `sh` instead of `bash` 