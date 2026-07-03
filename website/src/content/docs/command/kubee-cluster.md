---
title: kubee-cluster command
---

The `kubee-cluster` command manages the hosts of the clusters.

# Command

## PLAY

`play`:

* Hardened the Operating System
* Operating System package upgrade
* Kubernetes installation

Os gets upgraded automatically on each node every 24 hours and reboot safely with
the [Kubernetes Reboot Daemon](https://github.com/kubereboot/kured) to performs safe automatic node reboots

## UPGRADE

If you are on a vps, it's a good time to do a snapshot.

`upgrade` will upgrade Kubernetes on your cluster if the [k3s version](#k3s-version) is higher.

On a `upgrade`:

* if the kubee chart `kubernetes-monitoring` is installed, you may get some alerting
* the system pods will restart
* the cluster should become again healthy in a couple of minutes.

To avoid alerts, you need a cluster with a minimum 2 control plane/master node to maintain quorum when one goes down for
upgrading.

You can automate it with the K3 system upgrade controller https://github.com/rancher/system-upgrade-controller

# Metadata

## K3s version

The `k3s version` can be specified:

* using an inventory file with the `k3s_version` var
* using the default kubee inventory file, the environment variable: `KUBEE_CLUSTER_K3S_TOKEN`

The `k3s versions` are available at: https://github.com/k3s-io/k3s/releases

Example:

```bash
export KUBEE_CLUSTER_K3S_VERSION="v1.32.0+k3s1"
```

The value is made up of:

* `v1.32` is the [version of Kubernetes](https://kubernetes.io/releases/)
* `k3s1` is the version of the `k3s` wrapper.

# Copy KUBECONFIG and connection test

```bash
# env
export KUBECONFIG=~/.kube/config.new
# permission
chmod 600 "$KUBECONFIG"
kubectl config use-context k3s-ansible
# if on localhost
kubectl config set-cluster k3s-ansible --server=https://127.0.0.1:6443
kubectl config set-cluster k3s-ansible --server="https://$CLUSTER_API_SERVER_IP:6443"
kubectl cluster-info # we should connect to the API
kubectl get nodes # we should see a node
helm list -n kube-system
# change server (IP for now because the FQDN should be set before installing kube)
# otherwise `tls: failed to verify certificate: x509: certificate is valid for kube-test-server-01, kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local, localhost, not kube-test-server-01.xxx`
kubectl config rename-context k3s-ansible $KUBEE_CLUSTER_NAME
# test
kubectl cluster-info dump
```

### Test

Other tests: https://technotim.live/posts/k3s-etcd-ansible/#testing-your-cluster

## Dependencies

* `yq` to update kubeconfig
* `openssl` to generate a random token
* [ans-x (ansible)](https://github.com/gerardnico/ansible-x)
* `kubectl` to talk to the server and install kustomize apps
* `helm` to install helm package
* `docker` to create and run image

## Support

### Can't connect ? How to debug a connection

Check the [unable to connect with ansible](../runbooks/ansible-unable-to-connect.md) runbook.