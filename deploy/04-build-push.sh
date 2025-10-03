#!/bin/bash
source ./00-common.sh

# Dockerfile 위치 (프로젝트 루트)
PROJECT_ROOT=$(realpath ../)  # deploy/ 상위 디렉토리
IMAGE_FULL="${LOCAL_IP}:5000/spring-server:latest"

step "4️⃣ 이미지 빌드 및 Push"
podman build --layers=false -t ${IMAGE_FULL} "$PROJECT_ROOT"
podman push --tls-verify=false ${IMAGE_FULL}
minikube image load ${IMAGE_FULL}
success "이미지 빌드 및 Push 완료"
