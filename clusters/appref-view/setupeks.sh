#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

export INSTALL_REGISTRY_HOSTNAME=$(yq eval '.INSTALL_REGISTRY_HOSTNAME' $PARAMS_YAML)
export INSTALL_REGISTRY_USERNAME=$(yq eval '.INSTALL_REGISTRY_USERNAME' $PARAMS_YAML)
export INSTALL_REGISTRY_PASSWORD=$(yq eval '.INSTALL_REGISTRY_PASSWORD' $PARAMS_YAML)
export GIT_SSH_PRIVATE_KEY=$(yq eval '.GIT_SSH_PRIVATE_KEY' $PARAMS_YAML)
export GIT_KNOWN_HOSTS=$(yq eval '.GIT_KNOWN_HOSTS' $PARAMS_YAML)
export AGE_KEY=$(yq eval '.AGE_KEY' $PARAMS_YAML)
export AWS_ACCOUNT=$(yq eval '.AWS_ACCOUNT' $PARAMS_YAML)

eksctl utils associate-iam-oidc-provider --cluster appref-1 --approve
eksctl create iamserviceaccount --name cert-manager --namespace cert-manager --cluster appref-1 --role-name "appref1-cert-manager" \
    --attach-policy-arn arn:aws:iam::XXX:policy/cert-manager --role-only --approve
eksctl create iamserviceaccount --name external-dns --namespace tanzu-system-service-discovery --cluster appref-1 --role-name "appref1-external-dns" \
    --attach-policy-arn arn:aws:iam::XXX:policy/external-dns-policy --role-only --approve

