#!/usr/bin/env bash

set -e
set -o pipefail

DIR="$(dirname "$(realpath "$0")")"
cd $DIR

CLUSTER_NAME=$1
if [ "$CLUSTER_NAME" = "" ]; then
  echo missing cluster name
  exit 1
fi

offset=$(echo $CLUSTER_NAME | sed 's/.*-\([0-9]*\)/\1/g')
if [ "$offset" = "" ]; then
  offset="0"
else
  offset=$(($offset-1))
fi

export K8S_PORT=$((6443 + offset * 1000))
export HTTP_PORT=$((8080 + offset * 1000))

cat kind-config.yaml | envsubst > /tmp/kind-config.yaml

kind delete cluster --name $CLUSTER_NAME
kind create cluster --name $CLUSTER_NAME --config /tmp/kind-config.yaml

images="\
  quay.io/cilium/cilium:v1.15.3 \
  quay.io/cilium/operator-generic:v1.15.3 \
  quay.io/cilium/certgen:v0.1.9 \
  quay.io/jetstack/cert-manager-controller:v1.15.0 \
  quay.io/jetstack/cert-manager-startupapicheck:v1.15.0 \
  quay.io/jetstack/cert-manager-webhook:v1.15.0 \
  quay.io/jetstack/cert-manager-cainjector:v1.15.0 \
  registry.k8s.io/ingress-nginx/controller:v1.10.1 \
  registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1 \
  ghcr.io/kluctl/kluctl:v2.24.1 \
  ghcr.io/kluctl/template-controller:v0.8.3 \
"

for i in $images; do
  docker pull $i
  kind load docker-image --name $CLUSTER_NAME $i
done
