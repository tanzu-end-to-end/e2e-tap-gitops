#!/usr/bin/env bash 
set -o errexit -o nounset -o pipefail

kubectl delete clusterrolebinding/external-dns-viewer
kubectl delete clusterrole/external-dns
kubectl delete clusterrole crossplane-admin
kubectl delete clusterrolebinding tap-install-cluster-admin
kubectl delete clusterrolebinding tap-install-cluster-admin-role-binding
kubectl delete clusterrolebinding tap-telemetry-informer-admin    

kubectl delete clusterrole tap-install-cluster-admin                          
kubectl delete clusterrole tap-install-cluster-admin-role
kubectl delete clusterrole tap-telemetry-admin                                                                    │


kubectl delete clusterrole crossplane-admin

kubectl delete clusterrol crossplane-provider-helm
kubectl delete clusterrole crossplane
kubectl delete clusterrole crossplane:system:aggregate-to-crossplane
kubectl delete clusterrole crossplane-provider-kubernetes
kubectl delete clusterrolebinding crossplane-provider-helm
kubectl delete ns crossplane-system
kubectl delete customresourcedefinition/providerconfigs.helm.crossplane.io