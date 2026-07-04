---
title: Kubee Kustomize Project Support
---


A [Kubee Helmet chart](helmet-chart.md) supports kustomization project.

## Project Structure

Your kustomization file:

* can reference Helm templates directly. They will be rendered before passing them to `kustomize`
* should be in the Chart project directory
* can include the `${KUBEE_NAMESPACE}` environment variable. Why? To
  support [this case](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#installing-argo-cd-in-a-custom-namespace)

## Example of Kustomization File

```yaml
#file: noinspection KubernetesUnknownValues
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${KUBEE_NAMESPACE}
patches:
  - path: templates/patches/secret-patch.yml
  - patch: |-
      - op: replace
        path: /subjects/0/namespace
        value: ${KUBEE_NAMESPACE}
    target:
      kind: ClusterRoleBinding
resources:
  - https://raw.githubusercontent.com/orga/project/xxx/manifests/install.yaml
  - templates/resources/ingress.yml
```

> [!NOTE]
> Kustomize won't let you have multiple resources with the same GVK, name, and namespace
> because it expects each resource to be unique.
> If a resource template reports an error, setting it as a patch template, may resolve the problem.

## Example of Kustomization Project

Check the [kubee-argocd](https://github.com/bytle/kubee/tree/main/charts/argocd) chart for a kustomization example.

## How can I see the final output

When using the [helmet template command](../command/kubee-helmet.md#helmet---play--template),
the final file is located in the output directory at `out/chart-name/kustomized.yaml`.

