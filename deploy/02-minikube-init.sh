#!/bin/bash
source ./00-common.sh

step "2️⃣ Minikube 초기화 및 시작"
minikube delete || true
minikube start \
  --driver="podman" \
  --insecure-registry="${LOCAL_IP}:5000" \
  --apiserver-ips="127.0.0.1" \
  --apiserver-name="localhost" \
  --rootless=true \
  --memory=4096 --cpus=2
success "Minikube 시작 완료"
