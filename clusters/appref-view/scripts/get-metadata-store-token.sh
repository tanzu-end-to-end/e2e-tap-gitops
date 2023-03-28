#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

if [ ! $# -eq 1 ]; then
  echo "Must cluster name as args"
  exit 1
fi

CLUSTER_NAME=$1

kubectl config use-context $CLUSTER_NAME

export CA=$(kubectl get secret -n metadata-store app-tls-cert -o json | jq -r ".data.\"ca.crt\"")
yq e -i '.clusters.view.metadatastore.app_ca = env(CA)' $PARAMS_YAML

export AUTH_TOKEN=`kubectl get secret metadata-store-read-write-client -n metadata-store -ojsonpath="{.data.token}" | base64 -d`
yq e -i '.clusters.view.metadatastore.auth_token = env(AUTH_TOKEN)' $PARAMS_YAML
export SOPS_AGE_RECIPIENTS=$(yq eval '.AGE_RECIPIENTS' $PARAMS_YAML)
sops -e --input-type yaml --output-type yaml <(ytt -f meta-data-store-token-sensitive-values-template.yaml --data-values-file $PARAMS_YAML) > ../cluster-config/config/tap-install/meta-data-store-token-sensitive-values.sops.yaml

echo "commit new file to git to force update"