#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

if [ ! $# -eq 1 ]; then
  echo "Must cluster name as args"
  exit 1
fi
CONTEXT=$1

kubectl config use-context $1

export CA=$(kubectl get secret -n metadata-store app-tls-cert -o json | jq -r ".data.\"ca.crt\"")
yq e -i '.clusters.metadatastore.app_ca = env(CA)' $PARAMS_YAML

export AUTH_TOKEN=`kubectl get secret metadata-store-read-write-client -n metadata-store -ojsonpath="{.data.token}" | base64 -d`
yq e -i '.clusters.metadatastore.auth_token = env(AUTH_TOKEN)' $PARAMS_YAML

export SOPS_AGE_RECIPIENTS=$(yq eval '.AGE_RECIPIENTS' $PARAMS_YAML)

sops -e --input-type yaml --output-type yaml <(ytt -f templates/values/meta-data-store-token-sensitive-values-template.yaml  --data-values-file $PARAMS_YAML) > ../cluster-config/values/meta-data-store-token-sensitive-values-template.sops.yaml
