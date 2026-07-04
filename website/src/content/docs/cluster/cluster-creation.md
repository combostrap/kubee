---
title: How to create a cluster
---

## About

This page shows you how to create a [cluster](cluster.md)

## Example

You can see clusters example at [clusters example](https://github.com/bytle/kubee/tree/main/examples/clusters)

## Steps

### Versions (Helm 3 required)

When installing with brew, the version are already set for you.

For Helm, we don't support yet version 4 as they changed
the [post renderer as plugin](https://helm.sh/docs/overview/#post-renderers-implemented-as-plugins).

Be sure to have version 3 only.

```bash
helm version
# othewise
brew install helm@3
brew link --force helm@3 # because it's keg only meaning that it's in its own directory because it does not follow the main helm
```

We develop also with the ansible version 14

```bash
brew install ansible@14
brew link --force ansible@14 # because it's keg only meaning that it's in its own directory because it does not follow the main helm
```

### Create your clusters directory

A `clusters directory` is a directory that contains one or more cluster directory.

In your `.bashrc`

```bash
export KUBEE_CLUSTERS_PATH=~/kubee/clusters
```

Create your clusters directory

```bash
mkdir -p "$KUBEE_CLUSTERS_PATH"
```

### Create your cluster

#### Create a cluster directory

Create a `cluster directory`

```bash
KUBEE_CLUSTER_NAME=my-cluster
mkdir -p "$KUBEE_CLUSTERS_PATH/$KUBEE_CLUSTER_NAME"
```

#### Create a cluster values files

```bash
touch "$MY_CLUSTER_PATH/values.yaml"
```

#### Create your environment

Environment variables are set up in `.envrc`

```bash
touch "$KUBEE_CLUSTERS_PATH/$KUBEE_CLUSTER_NAME/.envrc"
```

### Set the infra value env

Set at minimal the following environment variables in your cluster values files:

* the full qualified server hostname. ie `server-01.example.com`
* the server ip
* the k3s token - A random secret value

Example:

* in the console, generate a k3s token with:

```bash
openssl rand -base64 64 | tr -d '\n'
```

* use it in `.envrc`:

```bash
export KUBEE_INFRA_K3S_TOKEN='bib7F0biIxpUUuOJJpjs9EgzqViHjAVna3MyxGbTq++gjXf6tm7y5c7' # don't change it
```

* With a password manager such as [pass or gopass](../general/pass.md)

```bash
# once to store your token
# pass insert kubee/k3s/token
export KUBEE_INFRA_K3S_TOKEN=$(pass kubee/k3s/token)
```

* Set the values in your cluster values file

```yaml
kubernetes:
  k3s:
    token: '${KUBEE_INFRA_K3S_TOKEN}'
  hosts:
    servers:
      - fqdn: 'server-01.example.com'
        ip: '188.245.43.202'
    all:
      connection:
        username: root
        type: 'ssh'
```

* Check that all cluster infra values has been set by printing the inventory

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" cluster conf
```

```yaml
k3s_cluster:
  children:
    server:
      hosts:
        node-name.example.com:
          ....
```

### Connection: Set your cluster private key file

By default, `kubee` will load and use:

* the ssh agent key if running
* or the default ssh private key files.

If you don't use them, you can define your ssh private file via one of this 2 environment variables in the cluster
`.envrc` file:

* `KUBEE_INFRA_CONNECTION_PRIVATE_KEY_FILE` : a private key path (without any passphrase)
* `KUBEE_INFRA_CONNECTION_PRIVATE_KEY` : the private key content

Example `.envrc` file:

* From a file

```bash
export KUBEE_INFRA_CONNECTION_PRIVATE_KEY_FILE=~/.ssh/server_01_rsa
```

* From a secret store such as [pass](../general/pass.md)

```bash
export KUBEE_INFRA_CONNECTION_PRIVATE_KEY
KUBEE_INFRA_CONNECTION_PRIVATE_KEY=$(pass cluster_name/ssh/private_key)
```

You can check that you can connect to your cluster by pinging it

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" cluster ping
```

You should get

```
server-01.example.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

No luck? Check the [not able to connect](../runbooks/unable-to-connect-to-hosts.md) runbook

### Execute the cluster installation

Once, you can connect to your cluster, you can install it with the `play` command

Example:

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" cluster play
```

The `play` command is idempotent, meaning that you can run it multiple times.

If the app is:

* not installed, it will install and configure it
* installed, it will configure it

Any error? The k3s service does not start, check the [k3s fatal error](../runbooks/k3s-fatal-error.md) runbook

### Check that the installation on the server

* Check the config

```bash
k3s check-config
```

* Check that the service is running

```bash
systemctl status k3s.service
```

### Check that you can connect with kubectl

* on server

```bash
k3s kubectl cluster-info
```

* on your laptop (on the client), the installation should have copied
  the [kubeconfig](../general/kubeconfig-connection.md)

```bash
cat ~/.kube/config
```

If not present, you
can [copy it from the server](../runbooks/kubectl-unable-to-connect.md#how-to-take-a-new-master-k3s-config-if-expired)

Then, you can connect:

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" kubectl cluster-info
```

You should get:

```txt
Kubernetes control plane is running at https://x.x.x.x:6443
CoreDNS is running at https://x.x.x.x:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://x.x.x.x:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy
```

If not and that the k3s service is running, check the [kubectl connect](../runbooks/kubectl-unable-to-connect.md)
runbook

### Install applications in the Kubernetes app

With [kubee helmet](../command/kubee-helmet.md), you can now install apps with
any [kubee charts](../helmet/helmet-chart.md)

Example:

* Install the Traefik proxy

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" helmet play traefik
```

* Install `Cert Manager`

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" helmet play cert-manager
```

or install any [other Kubee Charts ](https://github.com/bytle/kubee/tree/main#list-of-kubee-charts)
