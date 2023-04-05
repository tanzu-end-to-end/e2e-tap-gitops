#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

if [ ! $# -eq 2 ]; then
  echo "Must cluster name as args"
  exit 1
fi

CLUSTER_NAME=$2

kubectl config use-context $1

# this will retrieve the pinniped endpoint which is not what we want.
#export API_SERVER_URL=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')
#yq e -i '.clusters.tap_gui.'$CLUSTER_NAME'.api_server_url = env(API_SERVER_URL)' $PARAMS_YAML

export API_SERVER_CA=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
yq e -i '.clusters.tap_gui.'$CLUSTER_NAME'.api_server_ca = env(API_SERVER_CA)' $PARAMS_YAML

export SA_TOKEN=$(kubectl -n tap-gui get secret tap-gui-viewer -n tap-gui -o json| jq -r '.data["token"]' | base64 --decode)
yq e -i '.clusters.tap_gui.'$CLUSTER_NAME'.sa_token = env(SA_TOKEN)' $PARAMS_YAML

echo "View cluster config updated, now you have to apply updates"
