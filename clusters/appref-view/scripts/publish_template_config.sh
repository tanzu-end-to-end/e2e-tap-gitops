#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

export SOPS_AGE_RECIPIENTS=$(yq eval '.AGE_RECIPIENTS' $PARAMS_YAML)

for f in ./templates/config/*.yaml
do
 foo=$(basename $f .yaml)
 echo "Processing $foo" # always double quote "$f" filename
 sops -e --input-type yaml --output-type yaml <(ytt -f $f --data-values-file $PARAMS_YAML) > ../cluster-config/config/tap-install/custom/$foo.sops.yaml
done

