---
title: Unable to connect
---

## Steps

### Try to connect

With the default `KUBECONFIG` env or file (ie `~/.kube/config`)

```bash
kubee kubectl cluster-info
```

* with a specific [kubeconfig](../general/kubeconfig-connection.md)

```bash
KUBECONFIG=~/.kube/k3s.yaml kubee kubectl cluster-info
```

More info: https://docs.k3s.io/cluster-access

### Check if your certificate is not expired

```bash
kubee cert config-client
# with a specific file
KUBECONFIG=~/.kube/k3s.yaml kubee kubectl cluster-info
```

Example of certificate expired properties with

* `Not After : Jun 24 09:29:44 2025 GMT`
* `Not After : Mar 31 09:29:07 2026 GMT`

Example of expired certificate

```
0: Certificate
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 665787286463187628 (0x93d5a02719c0aac)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: CN=k3s-client-ca@1719221384
        Validity
            Not Before: Jun 24 09:29:44 2024 GMT
            Not After : Mar 31 09:29:07 2026 GMT
```

### How to take a new master k3s config if expired

* Grab the file `/etc/rancher/k3s/k3s.yaml` and copy it to `$HOME/.kube`
* Modify the `server` properties with your server ip. Example:

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: LSxxxxQo=
      server: https://189.246.42.265:6443
```

* Test a connection

```bash
KUBECONFIG=~/.kube/k3s.yaml kubee kubectl cluster-info
```

Optionally:

* you can rename it to the default: `$HOME/.kube/config`
* you can update the client cert if you use [pass to store it](../general/kubeconfig-pass.md)

```bash
# set your names
KUBEE_PASS_HOME=kubee
KUBEE_CLUSTER_NAME=beau # cluster name
KUBEE_USER_NAME=default # user name

# Save the new client certificate
KUBECONFIG=~/.kube/k3s.yaml kubectl config view --minify --raw --output 'jsonpath={$.users[0].user.client-certificate-data}' | pass insert -m "$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-certificate-data"
# Save the new client ley data
KUBECONFIG=~/.kube/k3s.yaml kubectl config view --minify --raw --output 'jsonpath={$.users[0].user.client-key-data}' | pass insert -m "$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-key-data"

# Test
kubee kubectl cluster-info
```
