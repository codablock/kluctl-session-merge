#!/usr/bin/env bash

set -e

DIR="$(dirname "$(realpath "$0")")"
cd $DIR

kind delete cluster
kind create cluster --config kind-config.yaml

images="\
  quay.io/cilium/cilium:v1.15.3 \
  quay.io/cilium/operator-generic:v1.15.3 \
  quay.io/cilium/certgen:v0.1.9 \
  quay.io/jetstack/cert-manager-controller:v1.15.0 \
  quay.io/jetstack/cert-manager-startupapicheck:v1.15.0 \
  quay.io/jetstack/cert-manager-webhook:v1.15.0 \
  quay.io/jetstack/cert-manager-cainjector:v1.15.0 \
  registry.k8s.io/ingress-nginx/controller:v1.10.1 \
  ghcr.io/kluctl/kluctl:v2.24.1 \
  ghcr.io/kluctl/template-controller:v0.8.3 \
"

for i in $images; do
  docker pull $i
  kind load docker-image $i
done
