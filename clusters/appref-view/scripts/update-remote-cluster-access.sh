#!/usr/bin/env bash 
: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}
export SOPS_AGE_RECIPIENTS=$(yq eval '.AGE_RECIPIENTS' $PARAMS_YAML)
BASEDIR=$(git rev-parse --show-toplevel)

if [ "$PWD" != "$BASEDIR" ]; 
then 
  cd $BASEDIR/clusters/appref-view/scripts
fi

./get-remote-cluster-tokens.sh eks.map-pas-global-house-worldwide-sales.us-east-2.appref-2 appref2
./get-remote-cluster-tokens.sh eks.map-pas-global-house-worldwide-sales.us-east-2.appref-1 appref1

sops -e --input-type yaml --output-type yaml <(ytt -f templates/values/remote-clusters-sensitive--values-template.yaml  --data-values-file $PARAMS_YAML) > ../cluster-config/values/remote-clusters-sensitive-values.sops.yaml
