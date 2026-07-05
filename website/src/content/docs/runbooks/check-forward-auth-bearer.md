---
title: Check Forward Auth Bearer
---


This page shows you how to verify the `forward-auth` middleware
installed when the [oauth chart](https://github.com/combostrap/kubee/tree/main/charts/oauth2-proxy) is installed.

## Steps

### Set the auth middleware on whomai

The bearer is not passed by default with the `forward-auth` middleware, we use then the `forward-auth-bearer` middleware

Apply `forward-auth-bearer` middleware on whoami in the [cluster file](../cluster/cluster-values.md)

```yaml
whoami:
  enabled: true
  auth_middleware: 'forward-auth-bearer'
  hostname: 'whoami-xxx.sslip.io.io'
```

### Deploy the whoami chart

```bash
kubee helmet -c clusertName play whoami
```

### Navigate to whoami web app

* Go to https://whoami-xxx.nip.io
* Grab the `Authorization: Bearer` Header value in the request

Example in this request, the value starts with `eyJhbGciOiJSU...`

```http request
Hostname: whoami-kubee-748cc6f455-mp6jj
IP: 127.0.0.1
GET / HTTP/1.1
Host: whoami-xxx.sslip.io
User-Agent: xxx
Accept: xxx
Accept-Encoding: xxx
Accept-Language: xxx
Authorization: Bearer eyJhbGciOiJSU...
```

### Decode the value

* Decode the payload at https://jwt.io/. Example:

```json
{
  "iss": "https://dex-xxx.nip.io",
  "sub": "CiQwOGE4Njg0Yi1kYjg4LTRiNzMtOTBhOS0zY2QxNjYxZjU0NjYSBWxvY2Fs",
  "aud": "oauth2-proxy",
  "exp": 1739983694,
  "iat": 1739897294,
  "at_hash": "HtDam6UvwOt6h07X2-BAkw",
  "c_hash": "tv4WJTo8QFFBJdKPQEJHLQ",
  "email": "admin@example.com",
  "email_verified": true,
  "name": "admin"
}
```
