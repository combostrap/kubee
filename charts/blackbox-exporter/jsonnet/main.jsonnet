local extValues = std.extVar('values');


local values = {

  namespace: extValues.namespace,
  version: extValues.version,
  rbac_enabled: extValues.prometheus.exporter_auth.kube_rbac_proxy.enabled,
  rbac_version: extValues.prometheus.exporter_auth.kube_rbac_proxy.version,
  rbac_resources: extValues.prometheus.exporter_auth.kube_rbac_proxy.resources,
  grafana_hostname: extValues.grafana.hostname,
  grafana_enabled: extValues.grafana.enabled,
  grafana_name: extValues.grafana.name,
  mixin_probe_failed_interval: extValues.mixin.alerts.probe_failed_interval,
  mixin_alerts_enabled: extValues.mixin.alerts.enabled,
  mixin_dashboard_enabled: extValues.mixin.dashboard.enabled,
  reloader_version: extValues.reloader.version,
  blackbox_conf_enabled: extValues.conf.enabled,
  blackbox_conf_modules: extValues.conf.modules,
  blackbox_resources: extValues.resources,
  blackbox_hostname: extValues.hostname,
  traefik_namespace: extValues.traefik.namespace,
  traefik_auth_middelware_name: extValues.traefik.auth.middleware_name,
  cert_manager_enabled: extValues.cert_manager.enabled,
  cert_manager_issuer_name: extValues.cert_manager.issuers.public.name,


};


local blackBoxExporterKp = (import 'kube-prometheus/components/blackbox-exporter.libsonnet')(values {
  image: 'quay.io/prometheus/blackbox-exporter:v' + values.version,
  configmapReloaderImage: 'ghcr.io/jimmidyson/configmap-reload:v' + values.reloader_version,
  kubeRbacProxyImage: 'quay.io/brancz/kube-rbac-proxy:v' + values.rbac_version,
  modules: values.blackbox_conf_modules,
  kubeRbacProxy:: {
    resources: values.rbac_resources,
  },
  resources: values.blackbox_resources,
  // customization to make it easy to delete the rbac container
  [if values.rbac_enabled == false then 'internalPort']: 9115,
});


local blackBoxExporterKubee = blackBoxExporterKp {
  // Add traefik to networkPolicy
  // Does not work, we get a bad gaeway from Traefik,
  // we let it here but filter it out on the returned object
  [if values.blackbox_hostname != '' then 'networkPolicy']+: {
    spec+: {
      ingress+: [{
        from: [
          {
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/name': 'traefik',
              },
            },
          },
        ],
        ports: blackBoxExporterKp.networkPolicy.spec.ingress[0].ports,
      }],
    },
  },
  // Disable Rbac
  [if values.rbac_enabled == false then 'deployment']+: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            container
            for container in blackBoxExporterKp.deployment.spec.template.spec.containers
            if container.name != 'kube-rbac-proxy'
          ],
        },
      },
    },
  },
  // Don't delete the configuration
  // It permits the user to take over without breaking the deployment
  configuration+: {
    metadata+: {
      annotations+: {
        'helm.sh/resource-policy': 'keep',
      },
    },
  },
  // Without Rbacl the port is the http port
  [if values.rbac_enabled == false then 'service']+: {
    spec+: {
      ports: [
        if port.name == 'https' then port {
           name: 'http',
           targetPort: 'http',
        } else port
        for port in blackBoxExporterKp.service.spec.ports
        if port.name != 'probe' // same port as https
      ],
    },
  },
  // Add ingress
  [if values.blackbox_hostname != '' then 'ingress']: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: blackBoxExporterKp._metadata {
      annotations+: {
        'traefik.ingress.kubernetes.io/router.entrypoints': 'websecure',
        'traefik.ingress.kubernetes.io/router.tls': 'true',
        /* Auth*/
        'traefik.ingress.kubernetes.io/router.middlewares': values.traefik_namespace + '-' + values.traefik_auth_middelware_name + '@kubernetescrd',
        assert !(values.rbac_enabled == true && values.traefik_auth_middelware_name != 'forward-auth-bearer') : 'Error: With Rbac enabled (' + values.rbac_enabled + '), the traefik middleware should be forward-auth-bearer not (' + values.traefik_auth_middelware_name + ') to authenticate successfully.',
        // Issuer
        [if values.cert_manager_enabled then 'cert-manager.io/cluster-issuer']: values.cert_manager_issuer_name,
      },
    },
    spec: {
      rules: [
        {
          host: values.blackbox_hostname,
          http: {
            paths: [{
              backend: {
                service: {
                  name: blackBoxExporterKp._metadata.name,
                  port: {
                    number: blackBoxExporterKp._config.port,
                  },
                },
              },
              path: '/',
              pathType: 'Prefix',
            }],
          },
        },
      ],
      tls: [{
        hosts: [values.blackbox_hostname],
        secretName: 'blackbox-cert',
      }],
    },
  },

};


// Returned Objects
{
  ['blackbox-exporter-' + name]:
    blackBoxExporterKubee[name]
  for name in std.objectFields(blackBoxExporterKubee)
  if !std.member(
        // We filter out network policy because even with our custom network policy,
        // we get a Bad Gayeway error from Traefik ???
        ['NetworkPolicy']
        + (
if values.blackbox_conf_enabled == false then ['ConfigMap'] else []
        ), blackBoxExporterKubee[name].kind
)
} +
(import 'kubee/mixin.libsonnet')(
  values {
    mixin: (import 'blackbox-exporter-mixin/mixin.libsonnet') + {
      _config+:: {
        grafanaUrl: 'https://' + values.grafana_hostname,
        probeFailedInterval: values.mixin_probe_failed_interval,
        blackboxExporterSelector: '',  // job value is not "blackbox-exporter" but the name of the CRD Probe ie probe/namespace/prob-crd-name
      },
    },
    mixin_name: 'blackbox-exporter',
    grafana_name: values.grafana_name,
    grafana_folder_label: 'BlackBox Exporter',
    grafana_hostname: values.grafana_hostname,
    grafana_enabled: values.grafana_enabled && values.mixin_dashboard_enabled,
    rules_enabled: true,
    alerts_enabled: values.mixin_alerts_enabled,
  }
)
