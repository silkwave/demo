#!/bin/bash
set -e
source ./00-common.sh

step "🟢 감지된 IP 정보"
echo "LOCAL_IP: $LOCAL_IP"

step "🟢 YAML 템플릿 환경변수 치환"
envsubst '${LOCAL_IP}' < deploy-myapp.yaml.template > deploy-myapp.yaml
echo "생성된 파일: deploy-myapp.yaml"

step "🟢 기존 리소스 정리"
kubectl delete deployment myapp --ignore-not-found
kubectl delete svc myapp --ignore-not-found

step "🟢 Deployment & Service 적용"
kubectl apply -f deploy-myapp.yaml

success "✅ MyApp 배포 완료"
