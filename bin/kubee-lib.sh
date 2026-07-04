# @name kubee-lib
# @brief A library of kubernetes functions
# @description
#     A library of kubernetes functions
#
#

# shellcheck source=./bashlib-array.sh
source "bashlib-array.sh"
# shellcheck source=./bashlib-echo.sh
source "bashlib-echo.sh"
# shellcheck source=./bashlib-command.sh
source "bashlib-command.sh"
# shellcheck source=./bashlib-bash.sh
source "bashlib-bash.sh"
# shellcheck source=./bashlib-path.sh
source "bashlib-path.sh"
# shellcheck source=./bashlib-template.sh
source "bashlib-template.sh"

# @description
#     Return the app name and namespace from a string
#     A qualified app name is made of one optional namespace and a name separated by a slash
#
# @arg $1 string The app name
# @example
#    read APP_NAMESPACE KUBEE_APP_NAME <<< "$(kube::get_qualified_app_name "$KUBEE_APP_NAME")"
#
# @stdout The app label ie `app.kubernetes.io/name=<app name>`
kube::get_qualified_app_name() {
  KUBEE_APP_NAME=$1
  IFS="/" read -ra NAMES <<< "$KUBEE_APP_NAME"
  case "${#NAMES[@]}" in
    '1')
      echo "${NAMES[0]} ${NAMES[0]}"
      ;;
    '2')
      echo "${NAMES[@]}"
      ;;
    *)
      echo::err "This app name ($KUBEE_APP_NAME) has more than 2 parts (ie ${#NAMES[@]})."
      echo::err "A qualified app name is made of one optional namespace and a name separated by a slash"
      echo::err "Example:"
      echo::err "  * traefik/traefik"
      echo::err "  * traefik"
      echo::err "  * prometheus/alertmanager"
      return 1
      ;;
  esac
}

# @description
#     Return the app label used to locate resources
#     It will return the label `app.kubernetes.io/name=<app name>`
#     This is the common app label as seen on the [common label page](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
#
# @arg $1 string The app name
# @example
#    APP_LABEL="$(kubee::get_app_label "$KUBEE_APP_NAME")"
#
# @stdout The app label ie `app.kubernetes.io/name=<app name>`
kubee::get_app_label() {
  echo "app.kubernetes.io/name=$1"
}

kubee::get_instance_label() {
  echo "app.kubernetes.io/instance=$1"
}

kubee::get_component_label() {
  echo "app.kubernetes.io/component=$1"
}

# @description
#     Function to search for resources across all namespaces by app name
#     and returns data about them
#
# @arg $1 string `x`                  - the kubee app name (mandatory)
# @arg $2 string `--type x`           - the resource type: pod, ... (mandatory)
# @arg $3 string `--custom-columns x` - the custom columns (Default to `NAME:.metadata.name,NAMESPACE:.metadata.namespace`)
# @arg $4 string `--headers`          - the headers (Default to `no headers`)
# @example
#    PODS="$(kube::get_resources_by_app_name --type pod "$KUBEE_APP_NAME")"
#
#    PODS_WITH_NODE_NAME="$(kube::get_resources_by_app_name --type pod --custom-columns "NAME:.metadata.name,NAMESPACE:.metadata.namespace,NODE_NAME:.spec.nodeName" "$KUBEE_APP_NAME")"
#
# @stdout The resources data (one resource by line) or an empty string
kube::get_resources_by_app_name() {

  local KUBEE_APP_NAME=''
  local RESOURCE_TYPE=''
  local CUSTOM_COLUMNS='NAME:.metadata.name,NAMESPACE:.metadata.namespace'
  local NO_HEADERS="--no-headers"

  # Parsing the args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      "--type")
        shift
        RESOURCE_TYPE=$1
        shift
        ;;
      "--custom-columns")
        shift
        CUSTOM_COLUMNS=$1
        shift
        ;;
      "--headers")
        NO_HEADERS=""
        shift
        ;;
      *)
        if [ "$KUBEE_APP_NAME" == "" ]; then
          KUBEE_APP_NAME=$1
          shift
          continue
        fi
        if [ "$RESOURCE_TYPE" == "" ]; then
          RESOURCE_TYPE=$1
          shift
          continue
        fi
        echo::err "Too much arguments. The argument ($1) was unexpected"
        return 1
        ;;
    esac
  done

  if [ "$KUBEE_APP_NAME" == "" ]; then
    echo::err "At least, the app name as argument should be given"
    return 1
  fi
  if [ "$RESOURCE_TYPE" == "" ]; then
    echo::err "The resource type is mandatory and was not found"
    return 1
  fi

  IFS="/" read -ra KUBEE_APP_NAMES <<< "$KUBEE_APP_NAME"
  local APP_LABELS=()
  case "${#KUBEE_APP_NAMES[@]}" in
    "1")
      # App Label
      APP_LABELS+=("$(kubee::get_instance_label "$KUBEE_APP_NAME")")
      ;;
    "2")
      APP_LABELS+=("$(kubee::get_instance_label "${KUBEE_APP_NAMES[0]}")")
      APP_LABELS+=("$(kubee::get_component_label "${KUBEE_APP_NAMES[1]}")")
      ;;
    *)
      echo::err "A kubee app name has one or 2 parts ($KUBEE_APP_NAME)"
      return 1
      ;;
  esac

  #
  # Customs columns is a Json path wrapper.
  # Example:
  #     COMMAND="kubectl get $RESOURCE_TYPE --all-namespaces -l $APP_LABEL -o jsonpath='{range .items[*]}{.metadata.name}{\" \"}{.metadata.namespace}{\"\n\"}{end}' 2>/dev/null"
  #
  COMMAND="kubectl get $RESOURCE_TYPE --all-namespaces -l $(
    IFS=","
    echo "${APP_LABELS[*]}"
  ) -o custom-columns='$CUSTOM_COLUMNS' $NO_HEADERS 2> ${COMMAND_STDOUT_FD:-"/dev/null"}"
  echo::eval "$COMMAND"

}

# @description
#     Function to search for 1 resource across all namespaces by app name
#     and returns data
#
# @arg $1 string `x`           - The app name
# @arg $2 string `--type type` - The resource type (pod, ...)
# @arg $3 string `--custom-columns x` - the custom columns (Default to `NAME:.metadata.name,NAMESPACE:.metadata.namespace`)
# @arg $4 string `--headers`          - the headers (Default to `no headers`)
# @example
#    read -r POD_NAME POD_NAMESPACE <<< "$(kubee::get_resource_by_app_name --type pod "$KUBEE_APP_NAME" )"
#    if [ -z "$POD_NAME" ]; then
#        echo "Error: Pod not found with label $(kubee::get_app_label $KUBEE_APP_NAME)"
#        exit 1
#    fi
#
# @stdout The resource name and namespace separated by a space or an empty string
# @exitcode 1 - if too many resource was found
kubee::get_resource_by_app_name() {
  RESOURCES=$(kube::get_resources_by_app_name "$@")
  RESOURCE_COUNT=$(echo "$RESOURCES" | sed '/^\s*$/d' | wc -l)
  if [ "$RESOURCE_COUNT" -gt 1 ]; then
    echo "Error: Multiple resource found with the label app.kubernetes.io/name=$KUBEE_APP_NAME:"
    echo "$RESOURCES"
    exit 1
  fi
  echo "$RESOURCES"
}

# @description
#     Return a json path to be used in a `-o jsonpath=x` kubectl option
# @arg $1 string The Json expressions (Default to: `.metadata.name .metadata.namespace`)
kube::get_json_path() {
  JSON_DATA_PATH_EXPRESSIONS=${1:-'.metadata.name .metadata.namespace'}
  JSON_PATH='{range .items[*]}'
  for DATA_EXPRESSION in $JSON_DATA_PATH_EXPRESSIONS; do
    # shellcheck disable=SC2089
    JSON_PATH="$JSON_PATH$DATA_EXPRESSION{\" \"}"
  done
  JSON_PATH="$JSON_PATH{\"\n\"}{end}"
  echo "$JSON_PATH"
}

# @description
#     test the connection to the cluster
# @exitcode 1 - if the connection did not succeed
kube::test_connection() {

  if OUTPUT=$(kubectl cluster-info); then
    echo::info "Test Connection succeeded"
    return 0
  fi
  echo::err "No connection could be made with the cluster"

  if [ "${KUBECONFIG:-}" == "" ]; then
    echo::err "Note: No KUBECONFIG env found"
  else
    if [ ! -f "$KUBECONFIG" ]; then
      echo::err "The KUBECONFIG env file ($KUBECONFIG) does not exist"
    else
      echo::info "The file ($KUBECONFIG) may have bad cluster info"
      echo::err "Note: The config is:"
      kubectl config view
    fi
  fi

  echo::err "We got the following output from the connection"
  echo::err "$OUTPUT"
  return 1

}

# @description
#     Return the directory of a cluster
# @arg $1 string The package name
kubee::get_cluster_directory() {

  local CLUSTER_NAME="$1"
  # All packages directories in an array
  local KUBEE_CLUSTER_DIRS=()
  IFS=":" read -ra KUBEE_CLUSTER_DIRS <<< "${KUBEE_CLUSTERS_PATH:-}"
  # this works for executed script or sourced script
  local KUBEE_RESOURCE_CLUSTERS_DIR=""
  if ! KUBEE_RESOURCE_CLUSTERS_DIR=$(realpath "$KUBEE_RESOURCES_DIR/examples/clusters" 2> /dev/null); then
    echo "Warning: the example clusters were not found at $KUBEE_RESOURCES_DIR/examples/clusters"
  fi
  local KUBEE_CLUSTER_DIRS+=("$KUBEE_RESOURCE_CLUSTERS_DIR")
  for KUBEE_CLUSTER_DIR in "${KUBEE_CLUSTER_DIRS[@]}"; do
    if [ ! -d "$KUBEE_CLUSTER_DIR" ]; then
      echo::warn "The path ($KUBEE_CLUSTER_DIR) set in KUBEE_CLUSTERS_PATH does not exist or is not a directory"
      continue
    fi
    local CLUSTER_DIR="$KUBEE_CLUSTER_DIR/${CLUSTER_NAME}"
    if [ -d "$CLUSTER_DIR" ]; then
      echo "$CLUSTER_DIR"
      return
    fi
  done
  echo::err "No cluster directory found with the name ($CLUSTER_NAME) in"
  echo::err "  * the distribution cluster directory (${KUBEE_RESOURCE_CLUSTERS_DIR}) "
  echo::err "  * the paths of the KUBEE_CLUSTERS_PATH variable (${KUBEE_CLUSTERS_PATH:-'not set'})"
  return 1

}

# @description
#     Print Data Connection values for debugging purpose
#     No args
kubee::print_connection_env() {
  echo::err "Data Connection Values:"
  echo::err "KUBEE_USER_NAME             : $KUBEE_USER_NAME"
  echo::err "KUBEE_CLUSTER_NAME          : $KUBEE_CLUSTER_NAME"
  echo::err "KUBEE_CLUSTER_SERVER_IP  : ${KUBEE_CLUSTER_SERVER_IP:-}"
  echo::err ""
  echo::err "Did you set the cluster name or a KUBECONFIG env?"
}

# @description
#     Take a kubeconfig from a context
kubee::print_kubeconfig_from_pass() {

  local path="$KUBEE_PASS_HOME/kubeconfig/$KUBEE_CONTEXT_NAME"
  if ! KUBECONFIG_VALUE="$(pass "$path" )"; then
    echo::warning "No kubeconfig file found in pass at $path"
    return 1
  fi
  echo::debug "Kubeconfig found in pass at $path"
  echo "$KUBECONFIG_VALUE"

}

# @description
#     Generate a KUBECONFIG file from the pass manager
#     No args, only global env
# deprecated for kubee::print_kubeconfig_from_pass
kubee::print_kubeconfig_from_old() {

  # Paths
  PASS_CLIENT_TOKEN_PATH="$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-token"
  PASS_CLIENT_CERT_PATH="$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-certificate-data"
  PASS_CLIENT_KEY_DATA="$KUBEE_PASS_HOME/users/$KUBEE_USER_NAME/client-key-data"
  PASS_CLUSTER_CERT_PATH="$KUBEE_PASS_HOME/clusters/$KUBEE_CLUSTER_NAME/certificate-authority-data"
  PASS_CLUSTER_SERVER_PATH="$KUBEE_PASS_HOME/clusters/$KUBEE_CLUSTER_NAME/server"

  ###################
  # Client
  ###################
  # Token?
  if ! KUBEE_CLIENT_TOKEN=$(pass "$PASS_CLIENT_TOKEN_PATH" 2> /dev/null); then
    KUBEE_CLIENT_TOKEN=""
    if ! KUBEE_CLIENT_CERTIFICATE_DATA=$(pass "$PASS_CLIENT_CERT_PATH" 2> /dev/null); then
      echo::err "No client token or client certificate has been found in pass at $PASS_CLIENT_TOKEN_PATH and $PASS_CLIENT_CERT_PATH respectively"
      kubee::print_connection_env
      return 1
    fi
    # Private Key
    if ! KUBEE_CLIENT_KEY_DATA=$(pass "$PASS_CLIENT_KEY_DATA" 2> /dev/null); then
      echo::err "No client key has been found in pass at $PASS_CLIENT_TOKEN_PATH and $PASS_CLIENT_CERT_PATH respectively"
      kubee::print_connection_env
      return 1
    fi
  fi

  ###################
  # Cluster
  ###################
  if ! KUBEE_CLUSTER_CERTIFICATE_AUTHORITY_DATA=$(pass "$PASS_CLUSTER_CERT_PATH" 2> /dev/null); then
    echo::err "No cluster certificate authority has been found in pass at $PASS_CLUSTER_CERT_PATH"
    kubee::print_connection_env
    return 1
  fi

  if ! KUBEE_CLUSTER_SERVER=$(pass "$PASS_CLUSTER_SERVER_PATH" 2> /dev/null); then
    KUBEE_CLUSTER_SERVER_IP=${KUBEE_CLUSTER_SERVER_IP:-}
    if [ "$KUBEE_CLUSTER_SERVER_IP" == "" ]; then
      echo::err "No cluster server could found"
      echo::err "  No server data has been found in pass at $PASS_CLUSTER_PASS_CLUSTER_SERVER_PATH"
      echo::err "  No server ip was defined for the env KUBEE_CLUSTER_SERVER_IP"
      kubee::print_connection_env
      return 1
    fi
    KUBEE_CLUSTER_SERVER="https://$KUBEE_CLUSTER_SERVER_IP:6443"
    echo::debug "KUBEE_CLUSTER_SERVER ($KUBEE_CLUSTER_SERVER) built from KUBEE_CLUSTER_SERVER_IP"
  else
    echo::debug "KUBEE_CLUSTER_SERVER ($KUBEE_CLUSTER_SERVER) built from pass $PASS_CLUSTER_SERVER_PATH"
  fi

  cat <<- EOF
apiVersion: v1
clusters:
  - name: $KUBEE_CLUSTER_NAME
    cluster:
      certificate-authority-data: $KUBEE_CLUSTER_CERTIFICATE_AUTHORITY_DATA
      server: $KUBEE_CLUSTER_SERVER
contexts:
  - context:
      cluster: $KUBEE_CLUSTER_NAME
      namespace: $KUBEE_CONNECTION_NAMESPACE
      user: $KUBEE_USER_NAME
    name: $KUBEE_CONTEXT_NAME
current-context: $KUBEE_CONTEXT_NAME
kind: Config
preferences: {}
users:
  - name: $KUBEE_USER_NAME
    user:
      client-certificate-data: $KUBEE_CLIENT_CERTIFICATE_DATA
      client-key-data: $KUBEE_CLIENT_KEY_DATA
      token: $KUBEE_CLIENT_TOKEN
EOF

}

# @description
#     Set the KUBECONFIG env
#     And errored if it does not exists
kubee::set_kubeconfig_env_and_check() {
  kubee::set_kubeconfig_env || return $?

  if [ "${KUBECONFIG:-}" != "" ] && [ ! -f "$KUBECONFIG" ]; then
    echo::err "The \$KUBECONFIG variable points to the file $KUBECONFIG that does not exist"
    return 1
  fi

}

# @description
#     Set the KUBECONFIG env
#     This function should be called just before a kubectl command that needs KUBECONFIG
#     Why ? because it will ask for a password at an interval if pass is used
#     Note that this is a little bit useless if `pass` is used to store secrets in the `envrc` file of a cluster project,
#     as it will also trigger a gpg pinentry
kubee::set_kubeconfig_env() {

  if ! kubee::discover_kubeconfig; then
    return 1
  fi

  # check the config
  local context
  context=$(kubectl config current-context)
  if [ "$context" != "$KUBEE_CONTEXT_NAME" ]; then
    echo::debug "Current Context $context is not equal to the kubee context $KUBEE_CONTEXT_NAME"
    echo::debug "Trying to switch"
    if ! kubectl config use-context "$KUBEE_CONTEXT_NAME"; then
        echo::err "Current Kubeconfig context ($context) is not the same as the current context ($KUBEE_CONTEXT_NAME)"
        echo::err "And we were unable to switch to the context $KUBEE_CONTEXT_NAME"
        echo::err "exiting"
        # we exit because the code does not check anything for now
        exit 1
    fi
  fi
  echo::info "Connection Context (user@cluster) : $KUBEE_CONTEXT_NAME"

}

kubee::discover_kubeconfig(){

    if [ "${KUBECONFIG:-}" != "" ]; then
      echo::debug "KUBECONFIG env already set to: $KUBECONFIG"
      return
    else
      echo::debug "KUBECONFIG env not set"
    fi

    export KUBECONFIG="$HOME/.kube/config"
    if [ -f "$KUBECONFIG" ]; then
      echo::debug "KUBECONFIG set to the existing default config file: $KUBECONFIG"
      return
    else
      echo::debug "KUBECONFIG file ($KUBECONFIG) not found "
    fi

    if ! command::exists "pass"; then
      echo::err "KUBECONFIG was not found"
      echo::err "The pass command was not found, we cannot generate a KUBECONFIG file"
      return 1
    fi

    # Config does not work with process substitution (ie /dev/
    # It seems that it starts another process deleting/closing the file descriptor

    # Trap work exit  also on source
    # https://stackoverflow.com/questions/69614179/bash-trap-not-working-when-script-is-sourced
    # As what we want is to delete it after the main script
    # We just output the trap statement
    # Note: On kubectl, we could also just pass the data but we should
    # do that for all kubernetes clients (promtool, ...) and this is pretty hard
    KUBECONFIG="$KUBEE_RUNTIME_DIR/kubee-config" # we create a shared memory file because we test the presence of the file
    # >| to force overwrite
    if ! kubee::print_kubeconfig_from_pass >| "$KUBECONFIG"; then
      echo::err "Error while generating the config file with pass"
      return 1
    fi
    if [ ! -f "$KUBECONFIG" ]; then
      echo::err "Internal Error: KUBECONFIG path does not exist. Value:\n$KUBECONFIG"
      exit 1
    fi
    chmod 0600 "$KUBECONFIG" # same permission as ssh key

}

# @description
#     Set the global env
kubee::set_env() {

  # Tmp dir
  # TMPDIR, TEMP and TMP may not be always set at the same time
  TMPDIR=${TMPDIR:-${TEMP:-${TMP:-/tmp}}}

  # The root directory where to store temporary files
  # This files are deleted
  KUBEE_RUNTIME_DIR="/dev/shm/kubee"
  mkdir -p "$KUBEE_RUNTIME_DIR"

  # Chart
  # This is a global constant because it's used by the kubee-cluster and kubee-helmet command as a cluster is also a chart
  CRD_SUFFIX="-crds"

  # KUBEE_RESOURCE_STABLE_CHARTS_DIR is not function local in the get_chart_directory function
  # because we use it in case of error in the message
  # this works for executed script or sourced script
  # This is a global constant because it's used by the kubee-cluster and kubee-helmet command as a cluster is also a chart
  export KUBEE_RESOURCE_STABLE_CHARTS_DIR
  # Kubee Home - the home directory
  # Why? Because if you use eval command with source, the BASH_SOURCE[0] becomes tmp
  if ! KUBEE_RESOURCE_STABLE_CHARTS_DIR=$(realpath "$KUBEE_RESOURCES_DIR/charts" 2> /dev/null); then
    echo "Warning: Release charts were not found (location $KUBEE_RESOURCES_DIR/charts)"
  fi

  # The cluster
  KUBEE_CLUSTER_NAME=${KUBEE_CLUSTER_NAME:-}

  # Cluster Directory
  if [ "$KUBEE_CLUSTER_NAME" != "" ]; then

    KUBEE_CLUSTER_DIR=$(kubee::get_cluster_directory "$KUBEE_CLUSTER_NAME")
    # Envrc
    # Used in all function
    KUBEE_ENV_FILE="${KUBEE_CLUSTER_ENV_FILE:-"$KUBEE_CLUSTER_DIR/.envrc"}"
    if [ -f "$KUBEE_ENV_FILE" ]; then
      echo::debug "Sourcing cluster env file $KUBEE_ENV_FILE"
      # shellcheck disable=SC1090
      if ! source "$KUBEE_ENV_FILE"; then
        echo::err "Error while importing the envrc file $KUBEE_ENV_FILE"
        return 1
      fi
    fi

    KUBEE_CLUSTER_VALUES_FILE="$KUBEE_CLUSTER_DIR/values.yaml"
    if [ ! -f "$KUBEE_CLUSTER_VALUES_FILE" ]; then
      echo::err "Cluster values file does not exist $KUBEE_CLUSTER_VALUES_FILE"
      return 1
    else
      echo::debug "Cluster values file found at $KUBEE_CLUSTER_VALUES_FILE"
    fi

  fi

  #############################
  # All env with default value
  # Should be after app envrc call
  #############################

  ## Connection namespace
  # The namespace for the connection (in the kubectl kubeconfig context)
  KUBEE_CHART_NAMESPACE=${KUBEE_CHART_NAMESPACE:-"default"}

  # The username for the connection (in the kubeconfig context)"
  KUBEE_USER_NAME=${KUBEE_USER_NAME:-"default"}

  # The connection namespace
  KUBEE_CONNECTION_NAMESPACE=${KUBEE_CONNECTION_NAMESPACE:-"default"}

  # The name of the context (in kubectx kubeconfig)"
  KUBEE_CONTEXT_NAME=${KUBEE_CONTEXT_NAME:-"$KUBEE_USER_NAME@$KUBEE_CLUSTER_NAME"}

  # The directory for the kubeconfig data in the pass store manager"
  KUBEE_PASS_HOME=${KUBEE_PASS_HOME:-"kubee"}

  # The busybox image to use for a shell in a busybox or ephemeral container"
  KUBEE_BUSYBOX_IMAGE=${KUBEE_BUSYBOX_IMAGE:-ghcr.io/gerardnico/busybox:latest}

}

# Return the cluster files with all variables expanded
kubee::get_cluster_values_file() {

  ############################
  # Variable Substitution
  # Check the variables
  if ! UNDEFINED_VARS=$(template::check_vars -f "$KUBEE_CLUSTER_VALUES_FILE"); then
    # Should exit because of the strict mode
    # but it was not working
    echo::err "Values variables missing: ${UNDEFINED_VARS[*]} in file $KUBEE_CLUSTER_VALUES_FILE"
    return 1
  fi
  local OUTPUT_DIR
  OUTPUT_DIR=${CHART_OUTPUT_VALUES_DIR:-$KUBEE_RUNTIME_DIR}
  local CLUSTER_VALUES_FILE="$OUTPUT_DIR/cluster-values-after-env-expansion.yml"
  envsubst < "$KUBEE_CLUSTER_VALUES_FILE" >| "$CLUSTER_VALUES_FILE"
  echo::debug "Cluster values files after env expansion: $CLUSTER_VALUES_FILE"
  echo "$CLUSTER_VALUES_FILE"

}

# Return the name of the values files or empty
#
# Return 2 values files adapted for Chart execution:
# * the cluster values files without the chart values
# * the chart values
#
# @env The cluster directory: KUBEE_CLUSTER_DIR
kubee::get_cluster_values_files_for_chart() {

  local KUBEE_CLUSTER_DIR=${KUBEE_CLUSTER_DIR:-}
  if [ "$KUBEE_CLUSTER_DIR" == "" ]; then
    echo::err "No Cluster specified"
    echo::debug "The Cluster env KUBEE_CLUSTER_DIR is empty"
    return 1
  fi

  # Alias
  # We just get rid of the crds for the CRD chart
  local ACTUAL_CHART_ALIAS
  ACTUAL_CHART_ALIAS=$(echo "${CHART_NAME#"$CRD_SUFFIX"}" | tr "-" "_")

  local CLUSTER_FILES=()

  # Cluster files
  local CLUSTER_VALUES_FILE
  CLUSTER_VALUES_FILE=$(kubee::get_cluster_values_file)
  CLUSTER_FILES+=("$CLUSTER_VALUES_FILE")

  local OUTPUT_DIR
  OUTPUT_DIR=${CHART_OUTPUT_VALUES_DIR:-$KUBEE_RUNTIME_DIR}
  # Extraction of the values in the cluster values files for the current chart
  # The cluster values need to lose their scope
  local CLUSTER_CHART_VALUES_FILE="$OUTPUT_DIR/cluster-chart-values.yml"
  local CHART_VALUES
  CHART_VALUES=$(echo::eval "yq '.$ACTUAL_CHART_ALIAS' $CLUSTER_VALUES_FILE")
  if [ "$CHART_VALUES" == "null" ]; then
    # CRD chart does not have any value in the cluster values files
    if [ "$CHART_TYPE" != "crds" ]; then
      echo::warn "No values found for the actual chart $ACTUAL_CHART_ALIAS in the cluster value file $KUBEE_CLUSTER_VALUES_FILE"
    fi
    echo "${CLUSTER_FILES[@]}"
    return
  fi
  # Write the value to the file
  echo "$CHART_VALUES" >| "$CLUSTER_CHART_VALUES_FILE"
  CLUSTER_FILES+=("$CLUSTER_CHART_VALUES_FILE")
  echo::debug "Returned the cluster chart values files $CLUSTER_CHART_VALUES_FILE"

  # Deletion of the actual chart property in the cluster values file does not occur anymore
  #
  # Why? So that the helm chart developer can reference the value with a full qualified name
  #
  # For example, in cert manager values.yaml, the reference {{ .Values.cert_manager.hostname }}
  # will be always available,
  # * when installing cert_manager
  # * but also when installing any another dependent chart.
  #
  # Deprecated: Delete the properties in the cluster values file
  # echo::debug "Delete the property $ACTUAL_CHART_ALIAS of the cluster values files for cleanness"
  # yq -i "del(.$ACTUAL_CHART_ALIAS)" "$CLUSTER_VALUES_FILE"

  # return
  echo "${CLUSTER_FILES[@]}"

}

# @description
#     Print the kubee values file for the chart
#
#
# @stdout - the values
# @args $1 - the chart name
kubee::print_chart_values() {

  local CHART_NAME="$1"
  local CHART_DIRECTORY
  if ! CHART_DIRECTORY=$(kubee::get_chart_directory "$CHART_NAME"); then
    echo::err "The chart $CHART_NAME could not be found"
    exit 1
  fi

  # Context
  local ACTUAL_CHART_FILE="$CHART_DIRECTORY/Chart.yaml"

  if [ ! -f "$ACTUAL_CHART_FILE" ]; then
    echo::err "No actual Chart file found ($ACTUAL_CHART_FILE does not exists)"
    return 1
  fi

  # All Chart values files to merge
  local CHART_VALUES_FILES=()

  # Add dependencies
  local DEPENDENCIES
  DEPENDENCIES="$(yq -r '.dependencies[] | [ (.name // "") + "," + (.alias // "") + "," + (.repository // "") + "," + ( .version // "")] | join("\n")' "$ACTUAL_CHART_FILE")"
  if [ "$DEPENDENCIES" != "" ]; then
    # Loop over the dependencies
    while IFS=, read -r DEPENDENCY_CHART_NAME DEPENDENCY_CHART_ALIAS DEPENDENCY_CHART_REPOSITORY DEPENDENCY_CHART_VERSION; do

      if [ "$DEPENDENCY_CHART_NAME" == "" ] || [ "$DEPENDENCY_CHART_NAME" == "null" ]; then
        echo::err "All dependency should have an name"
        echo::err "The repository $DEPENDENCY_CHART_REPOSITORY does not have one"
        return 1
      fi

      # We don't add external values files
      # They may use template:
      # name: {{ include "mailu.database.roundcube.secretName" . }}
      # and we get the error: error calling include: template: no template "mailu.database.roundcube.secretName" associated with template "gotpl"
      # Ref: https://github.com/Mailu/helm-charts/blob/98da259e46bf366ca03d7a9d3352d74c5bff7c66/mailu/values.yaml#L376
      # Otherwise we would need to create a copy of this chart with only the `values.yaml` template of the values chart
      if [[ $DEPENDENCY_CHART_NAME != kubee* ]]; then
        echo::debug "Skipped non kubee dependency chart $DEPENDENCY_CHART_NAME"
        continue
      fi

      # Alias is not mandatory and sometimes
      # You can't even change it (ie kubernetes-dashboard)
      # We generate a kubee alias
      if [ "$DEPENDENCY_CHART_ALIAS" == "" ] || [ "$DEPENDENCY_CHART_ALIAS" == "null" ]; then
        DEPENDENCY_CHART_ALIAS="$(echo "$DEPENDENCY_CHART_NAME" | tr "-" "_")"
        echo::debug "No alias found for the chart $DEPENDENCY_CHART_NAME. Alias generated to $DEPENDENCY_CHART_ALIAS"
      fi
      # The non-scoped dependency value file
      local SHM_DEPENDENCY_CHART_VALUES_FILE="$CHART_OUTPUT_VALUES_DIR/${DEPENDENCY_CHART_ALIAS}_default_non_scoped.yml"
      # In case of a symlink, the values file is in the charts directory
      local LOCAL_DEPENDENCY_CHART_PATH="$CHART_DIRECTORY/charts/$DEPENDENCY_CHART_NAME"
      if [ -d "$LOCAL_DEPENDENCY_CHART_PATH" ]; then
        local LOCAL_DEPENDENCY_CHART_VALUES_FILE="$LOCAL_DEPENDENCY_CHART_PATH/values.yaml"
        if [ -f "$LOCAL_DEPENDENCY_CHART_VALUES_FILE" ]; then
          cp -f "$LOCAL_DEPENDENCY_CHART_VALUES_FILE" "$SHM_DEPENDENCY_CHART_VALUES_FILE"
        else
          echo::warn "The dependency chart $DEPENDENCY_CHART_NAME found in charts/ has no values file"
          touch "$SHM_DEPENDENCY_CHART_VALUES_FILE"
        fi
      else
        echo::debug "The dependency chart $DEPENDENCY_CHART_NAME was not found locally at $LOCAL_DEPENDENCY_CHART_PATH"
        # Retrieve the value file with the show values command
        local HELM_SHOW_VALUE_COMMAND=(
          'helm' 'show' 'values'
        )
        if [ "$DEPENDENCY_CHART_REPOSITORY" == "" ]; then
          echo::err "The dependency chart $DEPENDENCY_CHART_NAME has no repository"
          echo::err "A dependency that is not in the charts/ directory should have a repository in Chart.yaml or be pulled into the charts/ directory."
          return 1
        fi
        case "$DEPENDENCY_CHART_REPOSITORY" in
          file://.*)
            # Local
            # The name of the chart is the path to the chart directory
            # Delete the file scheme (not supported by `helm get values`)
            DEPENDENCY_CHART="$CHART_DIRECTORY/${DEPENDENCY_CHART_REPOSITORY#"file://"}"
            HELM_SHOW_VALUE_COMMAND+=("$DEPENDENCY_CHART")
            ;;
          *)
            # Other scheme: Http, Oci scheme, ...
            HELM_SHOW_VALUE_COMMAND+=("--repo" "$DEPENDENCY_CHART_REPOSITORY")
            HELM_SHOW_VALUE_COMMAND+=("--version" "$DEPENDENCY_CHART_VERSION")
            HELM_SHOW_VALUE_COMMAND+=("$DEPENDENCY_CHART_NAME")
            ;;
        esac

        HELM_SHOW_VALUE_COMMAND+=(">| $SHM_DEPENDENCY_CHART_VALUES_FILE")
        # 2>COMMAND_STDOUT_FD to silence: walk.go:75: found symbolic link in path
        HELM_SHOW_VALUE_COMMAND+=("2>$COMMAND_STDOUT_FD")
        # In the following command, we cd in tempdir
        # because when the current directory is a Chart directory such as dex
        # We get: Error: Chart.yaml file is missing
        # No idea why???
        if ! echo::eval "cd ${TMPDIR};${HELM_SHOW_VALUE_COMMAND[*]}"; then
          echo::err "Error while trying to the get values for the Chart $DEPENDENCY_CHART_ALIAS"
          return 1
        fi
      fi

      # Scoping (ie adding the alias to the dependency values file)
      # The default value should be under the alias key (ie scoped)
      local DEPENDENCY_CHART_VALUES_FILE_WITH_SCOPE="$CHART_OUTPUT_VALUES_DIR/${DEPENDENCY_CHART_ALIAS}_default.yml"
      # --null-input flag: does not have any input as we create a new file
      if ! echo::eval "yq eval --null-input '.$DEPENDENCY_CHART_ALIAS = (load(\"$SHM_DEPENDENCY_CHART_VALUES_FILE\"))' >| $DEPENDENCY_CHART_VALUES_FILE_WITH_SCOPE"; then
        echo::err "Error while processing the chart values file $SHM_DEPENDENCY_CHART_VALUES_FILE"
        return 1
      fi
      rm "$SHM_DEPENDENCY_CHART_VALUES_FILE"
      CHART_VALUES_FILES+=("$DEPENDENCY_CHART_VALUES_FILE_WITH_SCOPE")
      echo::debug "Values file generated: ${DEPENDENCY_CHART_VALUES_FILE_WITH_SCOPE}"
    done <<< "$DEPENDENCIES"
  fi

  # Chart Own values files
  # Should be after the dependency so that in the merge they have priorities
  local CHART_VALUES_FILE="$CHART_DIRECTORY/values.yaml"
  if [ ! -f "$CHART_VALUES_FILE" ]; then
    echo::err "Values files ($CHART_VALUES_FILE) should exist"
    echo::err "Every kubee chart should have a values file to set the enabled and namespace properties"
    # mandatory because sometimes it's written values.yml and
    return 1
  fi
  CHART_VALUES_FILES+=("$CHART_VALUES_FILE")

  # The cluster values files should be last to be added in the set
  # as it has the higher priorities
  if ! CLUSTER_VALUE_FILES=$(kubee::get_cluster_values_files_for_chart); then
    echo::err "Error while creating the values file"
    echo::err "Note: Cluster file is mandatory because installing without it would delete resources such as Ingress"
    return 1
  fi
  echo::debug "Adding cluster files: $CLUSTER_VALUE_FILES"
  IFS=" " read -ra CLUSTER_VALUE_FILES_ARRAY <<< "${CLUSTER_VALUE_FILES}"
  CHART_VALUES_FILES+=("${CLUSTER_VALUE_FILES_ARRAY[@]}")

  ###########################
  # Merge with helm itself
  # shellcheck disable=SC2016
  # https://mikefarah.gitbook.io/yq/commands/evaluate-all
  # Old command was echo::eval "yq eval-all '. as \$item ireduce ({}; . * \$item )' ${CHART_VALUES_FILES[*]}"
  # Values are merged from left to right
  local PATH_VALUES_CHART
  if ! PATH_VALUES_CHART=$(kubee::get_chart_directory "values"); then
    echo::debug "Internal error no chart directory found with the names values"
    return
  fi
  # Note
  # `yq --no-doc` at the end delete the doc separator `---`
  # Otherwise it's seen in jsonnet as an array of objects
  # By default helm adds the separator
  # ---
  ## Source: kubee-values/templates/values.yaml
  if ! echo::eval "helm template fake-release-name $PATH_VALUES_CHART --show-only templates/values.yaml -f $(array::join --sep ' -f ' "${CHART_VALUES_FILES[@]}") | yq --no-doc 'select(document_index == 0)'"; then
    echo::err "Error while merging the yaml files"
    return 1
  fi

}

# @description
#     Return the directory of a chart
# @arg $1 string The chart name
kubee::get_chart_directory() {

  local CHART_NAME="$1"
  # All packages directories in an array
  local KUBEE_CHARTS_DIRS=()
  IFS=":" read -ra KUBEE_CHARTS_DIRS <<< "${KUBEE_CHARTS_PATH:-}"
  local KUBEE_CHARTS_DIRS+=("$KUBEE_RESOURCE_STABLE_CHARTS_DIR")
  for KUBEE_PACKAGES_DIR in "${KUBEE_CHARTS_DIRS[@]}"; do
    if [ ! -d "$KUBEE_PACKAGES_DIR" ]; then
      echo::warn "The path ($KUBEE_PACKAGES_DIR) set in KUBEE_CHARTS_PATH does not exist or is not a directory"
      continue
    fi
    local APP_DIR="$KUBEE_PACKAGES_DIR/${CHART_NAME}"
    if [ -d "$APP_DIR" ]; then
      echo "$APP_DIR"
      return
    fi
  done
  return 1

}
