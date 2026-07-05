---
title: How to configure kubelogin with kubectl
---

We support [kubectl](../general/kubectl.md) [oidc login](../general/oidc.md) with
the [kubelogin oidc plugin](https://github.com/int128/kubelogin).

## How it works

When you run kubectl,

* kubelogin starts a local server
* kubelogin opens the browser and redirect your to dex,
* once logged in, dex redirects to the local kubelogin server
* kubelogin gets the bearer and stores it

## Steps

### Dex should be enabled

The [Dex charts](https://github.com/combostrap/kubee/tree/main/charts/dex) should be installed and configured

### Install kubelogin

[Install kubelogin](https://github.com/int128/kubelogin#setup)

### Change your kubeconfig file

Add a user oidc context in your [kubeconfig](../general/kubeconfig-connection.md)

Example: You should change below your `--oidc-issuer-url` and `--oidc-client-secret` secret

```yaml
users:
  - name: oidc
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1
        interactiveMode: Never
        command: kubectl
        args:
          - oidc-login
          - get-token
          - --token-cache-storage=keyring
          - --oidc-issuer-url=https://dex-xxxx.sslip.io
          - --oidc-client-secret=9Yub---your-secret---K0=
          - --oidc-client-id=kubectl
          - --oidc-extra-scope=profile
          - --oidc-extra-scope=audience:server:client_id:kubernetes
          - --oidc-extra-scope=email
          - --oidc-extra-scope=groups
```

### Initiate a connection

```bash
kubectl --user=oidc  cluster-info
```

#### Troubleshooting

If not successful, you need to check the bearer token.
The value should have the [kubernetes audience](../general/oidc.md#test-kubernetes-aud)

* Unset the `--token-cache-storage=keyring`, then the tokens are stored at:

```
$HOME\.kube\cache\oidc-login
```

* Get the value
* Go to https://www.jwt.io/ and decode it

### Switch the current to oidc and delete the default

If successful, switch the current user and delete the default one.

```bash
kubectl config set-context --current --user=oidc
kubectl config delete-user default
```
