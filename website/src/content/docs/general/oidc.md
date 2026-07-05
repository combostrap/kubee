---
title: Oidc
---

OIDC login is supported when the [dex chart](https://github.com/combostrap/kubee/tree/main/charts/dex) is installed/enabled.

## Clients

* [Kubectl](kubectl.md#oidc)

## Support

### Test Kubernetes Aud

The JWS Token should have the `Kubernetes` audience to log in to the Kubernetes API.
(ie they should be in the `trustedPeers` property of the `kubernetes` client in the dex `staticClients` config)

Get your [Bearer](../runbooks/check-forward-auth-bearer.md)

Example: WhoAmi Token as seen in https://jwt.io

```json
{
  "iss": "https://dex-xxx.sslip.io",
  "sub": "CiQwOGE4Njg0Yi1kYjg4LTRiNzMtOTBhOS0zY2QxNjYxZjU0NjYSBWxvY2Fs",
  "aud": [
    "kubernetes",
    "oauth2-proxy"
  ],
  "exp": 1740245547,
  "iat": 1740159147,
  "azp": "oauth2-proxy",
  "at_hash": "k2g1Ifln8kKAJdZ1QK6ZLw",
  "c_hash": "mgS6xLuU0uIrsAFA5dB8uA",
  "email": "foo@example.com",
  "email_verified": true,
  "name": "foo"
}
```