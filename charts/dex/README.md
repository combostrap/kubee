

 (if [enabled](https://kubee.bytle.net/helmet/chart-enabled) and secret
  is not empty)
* [argocd](https://github.com/bytle/kubee/blob/main/charts/argocd/README.md) (if [enabled](https://kubee.bytle.net/helmet/chart-enabled) and secret is not empty)
* [kubectl](https://kubee.bytle.net/general/kubectl)
* [postal](https://github.com/bytle/kubee/blob/main/charts/postal/README.md) (if [enabled](https://kubee.bytle.net/helmet/chart-enabled) and secret is not empty)

### Kubee Charts Features

  These [kubee charts](https://kubee.bytle.net/helmet/helmet-chart) add their features when `enabled`.

* [argocd](https://github.com/bytle/kubee/blob/main/charts/argocd/README.md)
* [cert-manager](https://github.com/bytle/kubee/blob/main/charts/cert-manager/README.md) adds [server certificates](https://cert-manager.io/docs/usage/certificate/) to the servers
* [traefik](https://github.com/bytle/kubee/blob/main/charts/traefik/README.md) creates an [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) if hostnames are defined

## Cluster Values Example

In your [cluster values file](https://kubee.bytle.net/cluster/cluster-values)
, you need to fill at minimum this values:
```yaml
dex:
  enabled: true
  hostname: 'dex.example.com'
  clients:
    # for traefik forward auth
    oauth2_proxy:
      secret: '${DEX_OAUTH_CLI_SECRET}'
    # for kubectl
    kubectl:
      secret: '${DEX_KUBECTL_CLI_SECRET}'
```

In the cluster `.envrc` file, set the env `DEX_OAUTH_CLI_SECRET` and `DEX_KUBECTL_CLI_SECRET` with your favorite secret store.

Example with [pass](https://kubee.bytle.net/general/pass):
```bash
export DEX_FORWARD_AUTH_CLI_SECRET
DEX_FORWARD_AUTH_CLI_SECRET=$(pass "cluster_name/dex/forward-auth-cli-secret")
```

## Installation

```bash
kubee --cluster cluster-name helmet play dex
```

Check the installation (hostname, cert) by hitting the discovery endpoint:

```bash
curl https://hostname/.well-known/openid-configuration
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clients.argocd | object | `{"client_id":"argocd","secret":""}` | ArgoCd Web client |
| clients.argocd_cli | object | `{"client_id":"argocd-cli"}` | ArgoCd terminal client (ie argocd login) |
| clients.kubectl | object | `{"client_id":"kubectl","secret":""}` | Kubectl (ie kubectl oidc-login) Added if the secret is not empty |
| clients.kubernetes.trusted_peers | list | `[]` | List of kubernetes trusted client id (All clients that needs kubernetes access should be in that list.) |
| clients.oauth2_proxy | object | `{"client_id":"oauth2-proxy","secret":""}` | Oauth2_proxy client |
| clients.others | list | `[]` | Other oidc clients definition to add your own clients. See the [doc](https://dexidp.io/docs/guides/using-dex/#configuring-your-app) |
| clients.postal | object | `{"client_id":"oauth2-proxy","secret":""}` | Postal client |
| connectors | list | `[]` | Additional [auth connectors](https://dexidp.io/docs/connectors) |
| enabled | bool | `false` | Boolean to indicate that this chart is or will be installed in the cluster |
| expiration.access_token_lifetime | int | `1440` | The access token lifetime (in minutes) 24h (1440m) is the [default](https://github.com/dexidp/dex/blob/65814bbd7746611a359408bb355fb4e12d6e2c14/config.yaml.dist#L89), 10m is the [recommended doc setting](https://dexidp.io/docs/configuration/tokens/#expiration-and-rotation-settings), 1m is the [recommended setting of Oauth proxy](https://oauth2-proxy.github.io/oauth2-proxy/configuration/session_storage). |
| expiration.refresh_token_lifetime | int | `10080` | The refresh token lifetime (in minutes), it forces users to reauthenticate 3960h (165 days) is the [dex default](https://github.com/dexidp/dex/blob/65814bbd7746611a359408bb355fb4e12d6e2c14/config.yaml.dist#L89), 168h (7 days, 10080m) is the [default cookie_expire value](https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview?_highlight=cookie_expire#cookie-options) |
| hostname | string | `""` | The public hostname (Required as you need a callback) |
| namespace | string | `"auth"` | The installation namespace |
| dex | object | | [Chart Dex values](https://github.com/dexidp/helm-charts/blob/dex-2.45.1/charts/dex/values.yaml) |

## Contrib / Dec

Dev and contrib documentation can be found [here](contrib/contrib.md)

