#!/bin/bash

cluster_name=workshop

account_id=$(aws sts get-caller-identity --query "Account" --output text)
registered_oidc_issuer=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text)
registered_oidc_id=$(echo $registered_oidc_issuer| cut -d '/' -f 5)
oidc_provider_check=$(aws iam list-open-id-connect-providers | grep $registered_oidc_id | cut -d "/" -f4 | rev | cut -c2- | rev)

if [ "" = $oidc_provider_check ]; then
  echo "Associating OIDC provider for new cluster"
  eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve 
else
  echo "Found OIDC provider with ID $oidc_provider_check.  Skipping creation."
fi

oidc_provider=$(echo $registered_oidc_issuer | sed -e "s/^https:\/\///")
read -r -d '' trust_doc << EOM
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:\${namespace}:\${service_account}"
        }
      }
    }
  ]
}
EOM

#echo "$trust_doc" | namespace=cert-manager service_account=cert-manager envsubst '$namespace,$service_account'
aws iam create-role --no-paginate --role-name $cluster_name-cert-manager --assume-role-policy-document "$(echo "$trust_doc" | namespace=cert-manager service_account=cert-manager envsubst '$namespace,$service_account')" --description "IAM Role for cert-manager in $cluster_name cluster"
aws iam attach-role-policy --role-name $cluster_name-cert-manager --policy-arn=arn:aws:iam::$account_id:policy/cert-manager

#echo "$trust_doc" | namespace=tanzu-system-service-discovery service_account=external-dns envsubst '$namespace,$service_account'
aws iam create-role --no-paginate --role-name $cluster_name-external-dns --assume-role-policy-document "$(echo "$trust_doc" | namespace=tanzu-system-service-discovery service_account=external-dns envsubst '$namespace,$service_account')" --description "IAM Role for external-dns in $cluster_name cluster"
aws iam attach-role-policy --role-name $cluster_name-external-dns --policy-arn=arn:aws:iam::$account_id:policy/external-dns-policy