#!/bin/bash
set -e
source ./00-common.sh

step "🟢 WSL2 호스트 IP 자동 감지"
HOST_IP=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
echo "Detected HOST_IP: $HOST_IP"

# LOCAL_IP는 기존 스크립트에서 정의된 레지스트리 IP
: "${LOCAL_IP:?LOCAL_IP 환경변수 필요}"

step "🟢 YAML 템플릿 적용"
envsubst '${HOST_IP} ${LOCAL_IP}' < deploy-myapp.yaml.template > deploy-myapp.yaml

step "🟢 Deployment & Service 적용"
kubectl apply -f deploy-myapp.yaml

success "✅ Deployment & Service 적용 완료"
