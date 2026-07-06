---
title: kubee-vault | Vault Operation
---

[//]: # (% kubee-vault-init-unseal&#40;1&#41; Version Latest | Init and unseal and vault)

`kubee vault` offers `vault` operations based on the `vault` chart.

## INIT

`kubee vault init` will:

* [init](https://developer.hashicorp.com/vault/docs/commands/operator/init) a fresh vault installation with `5` keys and
  a threshold of `3` (hardcoded)
* output on the console:
  * the output of the init operation
  * the unseal keys
  * the root token
* store in [pass](../general/pass.md):
  * at `kube/vault/keys`: the unseal keys
  * at `kube/vault/token`: the root token

## BACKUP

`kubee vault backup` will:

* stop vault
* start a temporary backup pod with the vault volume
* create a tar file of the data directory
* download the tar file in the [KUBEE_BACKUP_DIR](../general/kubee-env.md#kubee_backup_dir)
* verify the downloaded tar file by listing it
* delete the temporary backup pod
* start vault
* [unseal it](#unseal)

Example:

```bash
kubee --cluster SOURCE vault backup
kubee --cluster TARGET vault restore [fileName]
```

## RESTORE

> [!WARNING] restore delete the data directory
> Do a [backup](#backup) first


`kubee vault restore` will:

* stop vault
* start a temporary backup pod with the vault volume
* upload the tar file of the [KUBEE_BACKUP_DIR](../general/kubee-env.md#kubee_backup_dir)
  * The default name is: `vault-backup-YYYMMDD.tar.gz`
  * You can pass a file name as first argument
* delete the data directory
* extract the archive
* delete the temporary backup pod
* start vault
* [unseal it](#unseal)

Example:

```bash
kubee --cluster SOURCE vault backup
kubee --cluster TARGET vault restore [fileName]
```

## UNSEAL

`kubee vault backup` will unseal your vault with keys

* stored in [pass](../general/pass.md)
* at `kube/vault/keys`
* with one key by line

## DOWN

`kubee vault down` will scale down the vault deployment.

## UP

`kubee vault up` will scale up to 1 the vault deployment.

You need to execute [unseal](#unseal) after it.

