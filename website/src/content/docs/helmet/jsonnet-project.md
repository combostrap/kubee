---
title: Jsonnet Chart Support
---


A [Kubee Helmet chart](helmet-chart.md) can contain a Jsonnet project.

## Project Layout and Structure

The project:

* file system layout is:
  * the project directory is the subdirectory `jsonnet` of a chart
  * it contains optionally jsonnet bundler artifacts such as:
    * the manifest `jsonnetfile.json`
    * the `vendor` directory
  * the main file is called `main.jsonnet`
* can be:
  * opened as an independent project (by `VsCode`, `Idea`)
  * used as a [Jsonnet bundler dependency](#jsonnet-dependency)

## Jsonnet dependency

You can use it as dependency with the [jsonnet-bundler (jb)](https://github.com/jsonnet-bundler/jsonnet-bundler)

```bash
jb install https://github.com/workspace/repo/path/to/kubee/chart/jsonnet@main
```

## Execution

The files found at the project root directory with the extension `jsonnet` are executed:

* by default, in multimode, each key of the Json object is a manifest path (ie Jsonnet is executed with the `--multi`
  flag)
* in single mode (supported but not recommended) when the Jsonnet script name contains the term `single` (ie the
  expected output should be a single json manifest)

## Arguments

The Jsonnet script:

* get:
  * the `values` file via the `values` jsonnet external variable.
  * all default values via the `values` file (no value means error)
* if in multimode, should not output manifest path that contains directory (ie no slash in the name)

## Example

Minimal Multimode `main.jsonnet` Working Example:

```jsonnet
local kxValues = std.extVar('values');

// The name `values` is a standard because this is similar to helm
// (used for instance by [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus/blob/8e16c980bf74e26709484677181e6f94808a45a3/jsonnet/kube-prometheus/main.libsonnet#L17))
// The values objects are flatten to allows the standard values pattern (defaultValues + values) with basic inheritance https://jsonnet.org/ref/language.html#inheritance
local values =  {

  prometheus_namespace: kxValues.kubee.prometheus.namespace,

};

// A multimode json where each key represent the name of the generated manifest and is unique
{
   // no slash, no subdirectory in the file name
   // ie not `setup/my-manifest` for instance
   "my-manifest": {
       apiVersion: 'xxx',
       kind: 'xxx',
       metatdata: {
         namespace: values.prometheus_namespace
       }
    }
}
```

## Data Validation

To validate, you can take example in
our [validation library](https://github.com/combostrap/kubee/blob/785a4ca9877eb5d9facf4c4472e0b630d123a3b9/charts/alertmanager/jsonnet/kubee/validation.libsonnet).

Minimal Example:

```jsonnet
local extValues = std.extVar('values');
local validation = import './kubee/validation.libsonnet';
# This will throw an error if there is no property. It should as the values file should have the default.
local email = validation.getNestedPropertyOrThrow(extValues, 'kubee.cluster.adminUser.email');
# This will throw an error if there is no property and if this is the empty string.
local namespace = validation.notNullOrEmpty(extValues,'kubee.alertmanager.namespace');
{
    "my-manifest": {
       apiVersion: 'xxx',
       kind: 'xxx',
       metatdata: {
         namespace: namespace
       },
       spec: {
        email: email
       }
    }
}
```

## IDE Plugins

Ide Plugins, as of `2025-01-20`, choose your winner:

* The [Idea Databricks Jsonnet Plugin](https://plugins.jetbrains.com/plugin/10852-jsonnet) is:
  * heavy used by Databricks
  * can navigate the code. `import`
    * works only for relative path,
    * does not support `jpath`
  * does not support formatting the whole document
  * does not support variable renaming
  * no outline (structure)
  * supports object heritage structure when the parsing has no errors (ie if the object `config` defined as
    `config = defaults + values`, you will get to the `defaults` property structure in navigation and intellisense)
  * `Find usage (F7)` is not working
* The Grafana Json Server in [Vs Code](https://github.com/grafana/vscode-jsonnet)
  or [Intellij](https://plugins.jetbrains.com/plugin/18752-jsonnet-language-server)
  * navigation works only if the document has no errors
  * supports `jpath` (ie `import namespace/name` can be navigated)
  * supports formatting the whole document
  * supports variables renaming but not based on AST symbol (meaning that it's just a search and replace of a word by
    name, and you may ends up renaming just text, not symbol if the name is common such as values)
  * no outline (structure)
  * does not support object heritage structure (ie the object `config` defined as `config = defaults +values` will not
    get any intellisense on the `defaults` property)
  * `Find All References` is not working

What we do:

* in Databricks Intellij plugin, we develop
* in Grafana VsCode plugin, we format the whole file, we navigate `import` statement that uses `Jpath`.
