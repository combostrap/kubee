

## Metadata: Ownership via TXT records

only tagged records are viable for future deletion/update

Each record managed by External DNS is accompanied 
by a TXT record with a specific value to indicate 
that corresponding DNS record is managed by External DNS,
and it can be updated/deleted respectively. 

TXT records are limited to lifetimes of service/ingress objects 
and are created/deleted once k8s resources are created/deleted.

https://kubernetes-sigs.github.io/external-dns/latest/docs/initial-design/#ownership

## WebHook

```bash
# source is mandatory
docker run --rm \
  -e  KUBERNETES_SERVICE_HOST="localhost" \
  -e  KUBERNETES_SERVICE_PORT=688 \
  registry.k8s.io/external-dns/external-dns:v0.15.1 \
  --webhook-server \
  --provider=cloudflare \
  --source=ingress
```

## Image

```bash
docker inspect --format='{{.Config.Cmd}}' registry.k8s.io/external-dns/external-dns:v0.15.1
```
Entrypoint: `/ko-app/external-dns`

## Config / Flag

 * [Doc](https://kubernetes-sigs.github.io/external-dns/latest/docs/flags/)
 * [Code](https://github.com/kubernetes-sigs/external-dns/blob/724b86b8b867db9420c51b6a8bc9d26118bf213d/pkg/apis/externaldns/types.go#L423)
with default value [here](https://github.com/kubernetes-sigs/external-dns/blob/724b86b8b867db9420c51b6a8bc9d26118bf213d/pkg/apis/externaldns/types.go#L217C1-L217C29)

## Tls

* `--tls-ca`: When using TLS communication, the path to the certificate authority to verify server communications (optionally specify --tls-client-cert for two-way TLS)")
* `--tls-client-cert`: When using TLS communication, the path to the certificate to present as a client (not required for TLS)
* `--tls-client-cert-key`: When using TLS communication, the path to the certificate key to use with the client certificate (not required for TLS)")

## Monitoring

* [Cache Monitoring Metrics](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/rate-limits.md#monitoring)

## Bootstrap

```bash
kubee helmet dependency-update
dl-dependency-scripts
```


## WebHook

https://github.com/kubernetes-sigs/external-dns/pull/3063

webhook-provider-url: http://localhost:8888
```txt
WebhookProviderURL:           "http://localhost:8888",
WebhookProviderReadTimeout:   5 * time.Second,
WebhookProviderWriteTimeout:  10 * time.Second,
WebhookServer:                false,
```
`webhook-provider-url`: The URL of the remote endpoint to call for the webhook provider (default: http://localhost:8888)")
`webhook-provider-read-timeout`: The read timeout for the webhook provider in duration format (default: 5s)
`webhook-provider-write-timeout`: The write timeout for the webhook provider in duration format (default: 10s)
`webhook-server`: When enabled, runs as a webhook server instead of a controller. (default: false)



## Template

If --fqdn-template flag is specified, e.g. --fqdn-template={{.Name}}.my-org.com,
ExternalDNS will use service/ingress specifications for the provided template to generate DNS name.

## Test

```bash
cat > /tmp/dns-definition-test.yaml << EOF
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: combostraptest
spec:
  endpoints:
  - dnsName: test.combostrap.com
    recordTTL: 60
    recordType: A
    targets:
    - 10.0.0.2
EOF
```
```bash
kubee kubectl apply -n external-dns -f /tmp/dns-definition-test.yaml
```

## Dashboard

See example here:
https://gitlab.com/gitlab-com/runbooks/-/blob/6726ba6de1563c8623c0874755acfd09c205c6b5/dashboards/external-dns/main.dashboard.jsonnet

## Support 
### CRD ownership fix

```bash
kubee kubectl patch CustomResourceDefinition dnsendpoints.externaldns.k8s.io --type=merge   -p '{"metadata": {"labels": {"app.kubernetes.io/managed-by": "Helm"}, "annotations": {"meta.helm.sh/release-namespace": "external-dns", "meta.helm.sh/release-name": "external-dns-crds"}}}'
```

